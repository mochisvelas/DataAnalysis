SELECT * FROM STAGING.Orden o
				INNER JOIN Dimension.Partes p ON(p.ID_Parte = o.ID_Parte and o.Fecha_Orden BETWEEN p.FechaInicioValidez AND ISNULL(p.FechaFinValidez, '9999-12-31')) 
				INNER JOIN Dimension.Geografia g ON(g.ID_Ciudad = o.ID_Ciudad and o.Fecha_Orden BETWEEN g.FechaInicioValidez AND ISNULL(g.FechaFinValidez, '9999-12-31')) 
				INNER JOIN Dimension.Clientes c ON(c.ID_Cliente = o.ID_Cliente and o.Fecha_Orden between c.FechaInicioValidez and isnull(c.FechaFinValidez, '9999-12-31'))
				LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(o.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(o.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(o.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
			