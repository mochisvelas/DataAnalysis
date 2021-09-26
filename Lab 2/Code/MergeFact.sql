CREATE or ALTER PROCEDURE USP_MergeFact
as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
		--generar nuevo gui para la tabla de log, y declaracion de variables de maxima fecha de ejecucion con cantidad de registros afectados
		DECLARE @NuevoGUIDInsert UNIQUEIDENTIFIER = NEWID(), @MaxFechaEjecucion DATETIME, @RowsAffected INT
		--print @MaxFechaEjecucion
		--insertar en tabla de log
		INSERT INTO FactLog (ID_Batch, FechaEjecucion, NuevosRegistros)
		VALUES (@NuevoGUIDInsert,NULL,NULL)
		--merge me ayuda integrar tablas: si vienen cosas del destino que no existen insertarlas, si existen cosas en los dos modificarlas y si no esta en fuente pero si en el destino borrarlas
		--aca en los hechos lo que mas se espera son inserciones nuevas
		MERGE Fact.Orden AS T
		USING (
			select
				p.SK_Partes,
				g.SK_Geografia,
				c.SK_Clientes,
				DateKey,
				so.ID_Orden,
				so.ID_DetalleOrden,
				so.ID_Descuento,
				so.Cantidad,
				so.PorcentajeDescuento,
				so.Total_Orden,
				so.Fecha_Orden,
				so.Fecha_Modificacion,				
				getdate() as FechaCreacion,
				'ETL' as UsuarioCreacion, 
				NULL as FechaModificacion, 
				NULL as UsuarioModificacion, 
				@NuevoGUIDINsert as ID_Batch,
				'ssis' as ID_SourceSystem
			from staging.Orden so
			inner join Dimension.Partes p on (so.ID_Parte = p.ID_Parte and so.Fecha_Orden between p.FechaInicioValidez and isnull(p.FechaFinValidez, '9999-12-31'))
			inner join Dimension.Geografia g on (so.ID_Ciudad = g.ID_Ciudad and so.Fecha_Orden between g.FechaInicioValidez and isnull(g.FechaFinValidez, '9999-12-31'))
			inner join Dimension.Clientes c on (so.ID_Cliente = c.ID_Cliente and so.Fecha_Orden between c.FechaInicioValidez and isnull(c.FechaFinValidez, '9999-12-31'))
			left join Dimension.Fecha f on (CAST( (CAST(YEAR(so.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(so.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(so.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  = f.DateKey)
			) AS S ON (S.ID_Orden = T.ID_Orden)

		WHEN NOT MATCHED BY TARGET THEN --No existe en Fact
		INSERT (SK_Partes, SK_Geografia, SK_Clientes, DateKey, ID_Orden, ID_DetalleOrden, ID_Descuento, Cantidad, PorcentajeDescuento, Total_Orden, Fecha_Orden, Fecha_Modificacion, FechaCreacion, UsuarioCreacion, FechaModificacion, UsuarioModificacion, ID_Batch, ID_SourceSystem)
		VALUES (S.SK_Partes, S.SK_Geografia, S.SK_Clientes, S.DateKey, S.ID_Orden, S.ID_DetalleOrden, S.ID_Descuento, S.Cantidad, S.PorcentajeDescuento, S.Total_Orden, S.Fecha_Orden, S.Fecha_Modificacion, S.FechaCreacion, S.UsuarioCreacion,S.FechaModificacion, S.UsuarioModificacion, S.ID_Batch, S.ID_SourceSystem);

		SET @RowsAffected =@@ROWCOUNT

		SELECT @MaxFechaEjecucion=MAX(MaxFechaEjecucion)
		FROM(
			SELECT MAX(Fecha_Orden) as MaxFechaEjecucion
			FROM FACT.Orden
			UNION
			SELECT MAX(Fecha_Modificacion)  as MaxFechaEjecucion
			FROM FACT.Orden
		)AS A

		UPDATE FactLog
		SET NuevosRegistros=@RowsAffected, FechaEjecucion = @MaxFechaEjecucion
		WHERE ID_Batch = @NuevoGUIDInsert

		COMMIT
	END TRY
	BEGIN CATCH
		SELECT @@ERROR,'Ocurrio el siguiente error: '+ERROR_MESSAGE()
		IF (@@TRANCOUNT>0)
			ROLLBACK;
	END CATCH

END
go