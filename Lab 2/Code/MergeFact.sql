--Script de SP para MERGE
CREATE or ALTER PROCEDURE USP_MergeFact
as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
		DECLARE @NuevoGUIDInsert UNIQUEIDENTIFIER = NEWID(), @MaxFechaEjecucion DATETIME, @RowsAffected INT

		INSERT INTO FactLog ([ID_Batch], [FechaEjecucion], [NuevosRegistros])
		VALUES (@NuevoGUIDInsert,NULL,NULL)
		
		MERGE Fact.Orden AS T
		USING (
			SELECT 
			[SK_Partes],
			[SK_Geografia],
			[SK_Clientes],
			[DateKey],
			o.ID_Orden,
			o.ID_StatusOrden,
			o.Total_Orden,
			o.Fecha_Orden,
			getdate() as FechaCreacion,
			'ETL' as UsuarioCreacion,
			NULL as FechaModificacion,
			NULL as UsuarioModificacion,
			@NuevoGUIDINsert as ID_Batch,
			'ssis' as ID_SourceSystem
			FROM STAGING.Orden o
				INNER JOIN Dimension.Partes p ON(p.ID_Parte = o.ID_Parte and o.Fecha_Orden BETWEEN p.FechaInicioValidez AND ISNULL(p.FechaFinValidez, '9999-12-31')) 
				INNER JOIN Dimension.Geografia g ON(g.ID_Ciudad = o.ID_Ciudad and o.Fecha_Orden BETWEEN g.FechaInicioValidez AND ISNULL(g.FechaFinValidez, '9999-12-31')) 
				INNER JOIN Dimension.Clientes c ON(c.ID_Cliente = o.ID_Cliente and o.Fecha_Orden between c.FechaInicioValidez and isnull(c.FechaFinValidez, '9999-12-31'))
				LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(o.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(o.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(o.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
				) AS S ON (S.ID_Orden = T.ID_Orden)

		WHEN NOT MATCHED BY TARGET THEN --No existe en Fact
		INSERT ([SK_Partes], [SK_Geografia], [SK_Clientes], [DateKey], [ID_Orden], [ID_StatusOrden], [Total_Orden], [Fecha_Orden], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion], [ID_Batch], [ID_SourceSystem])
		VALUES (S.[SK_Partes], S.[SK_Geografia], S.[SK_Clientes], S.[DateKey], S.[ID_Orden], S.[ID_StatusOrden], S.[Total_Orden], S.[Fecha_Orden], S.[FechaCreacion], S.[UsuarioCreacion], S.[FechaModificacion], S.[UsuarioModificacion], S.[ID_Batch], S.[ID_SourceSystem]);

		SET @RowsAffected =@@ROWCOUNT

		SELECT @MaxFechaEjecucion=MAX(MaxFechaEjecucion)
		FROM(
			SELECT MAX(Fecha_Orden) as MaxFechaEjecucion
			FROM FACT.Orden
			UNION
			SELECT MAX(FechaModificacion)  as MaxFechaEjecucion
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