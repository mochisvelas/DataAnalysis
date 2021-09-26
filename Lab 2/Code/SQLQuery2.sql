use RepuestosWebDWH
go

select *
from Dimension.Fecha
go

select *
from Dimension.Partes
go

select *
from Dimension.Geografia
go

select *
from Dimension.Clientes
go

select *
from Fact.Orden
go

select *
from FactLog
go

select *
from staging.Orden

select *
from RepuestosWeb.dbo.Orden

insert into RepuestosWeb.dbo.Orden ([ID_Cliente], [ID_Ciudad], [ID_StatusOrden], [Total_Orden], [Fecha_Orden]) values
(1,1,1,69,GETDATE());

insert into RepuestosWeb.dbo.Detalle_orden ([ID_Orden], [ID_Partes], [ID_Descuento], [Cantidad]) values
(1,1,1,20);

select * from RepuestosWeb.dbo.Orden

SELECT ISNULL(MAX(FechaEjecucion),'1900-01-01') AS UltimaFecha
FROM FactLog

SELECT o.ID_Orden, 
c.ID_Cliente,
o.ID_Ciudad,
       o.ID_StatusOrden,
	   do.ID_Partes,
       o.Total_Orden,
	   o.Fecha_Orden,
       o.FechaModificacion 
FROM dbo.Orden o
inner join dbo.Clientes c on (c.ID_Cliente = o.ID_Cliente)
inner join dbo.Detalle_orden do on (do.ID_Orden = o.ID_Orden)
WHERE ((Fecha_Orden>'2021-09-19') OR (FechaModificacion>'2021-09-19'))



SELECT o.ID_Orden, 
c.ID_Cliente,
o.ID_Ciudad,
       o.ID_StatusOrden,
	   do.ID_Partes,
       o.Total_Orden,
	   o.Fecha_Orden,
       o.FechaModificacion 
FROM RepuestosWeb.dbo.Orden o
inner join RepuestosWeb.dbo.Clientes c on (c.ID_Cliente = o.ID_Cliente)
inner join RepuestosWeb.dbo.Detalle_orden do on (do.ID_Orden = o.ID_Orden)


-====================
INSERT INTO Orden (ID_Cliente,ID_Ciudad,ID_StatusOrden,Total_Orden,Fecha_Orden) values(1,1,1,1111.00,getdate())
insert into Detalle_orden (ID_Orden,ID_Partes,ID_Descuento,Cantidad) values (2,1,1,2)

select * from RepuestosWeb.dbo.Orden