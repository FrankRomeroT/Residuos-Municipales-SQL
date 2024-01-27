CREATE DATABASE Residuos_Municipales_Anuales

USE Residuos_Municipales_Anuales

CREATE TABLE Residuos(
FECHA_CORTE DATE ,
N_SEC INT,
UBIGEO INT,
REG_NAT VARCHAR(50),
DEPARTAMENTO VARCHAR(50),
PROVINCIA VARCHAR(50),
DISTRITO VARCHAR(100),
POB_TOTAL INT,
POB_URBANA INT,
POB_RURAL INT,
GPC_DOM float,
QRESIDUOS_DOM float,
QRESIDUOS_NO_DOM float,
QRESIDUOS_MUN float,
PERIODO DATE)

Create Table Población_Real(
Poblacion INT,
Año INT)

INSERT INTO Población_Real (Año, Poblacion)
VALUES
    (2014, 29616414),
    (2015, 29964499),
    (2016, 30422831),
    (2017, 30973992),
    (2018, 31562130),
    (2019, 32131400),
    (2020, 32625948),
    (2021, 33715471)


BULK INSERT Residuos
FROM 'C:\Users\FRANK\Desktop\Portafolio\SQL - Power Bi\Residuos municipales\Residuos municipales generados anualmente.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2)



SELECT DISTINCT PR.Poblacion, PR.Año
FROM Residuos AS R
JOIN Población_Real AS PR ON YEAR(R.PERIODO) = PR.Año;


-- 1 ¿Cuál es la cantidad total de residuos municipales generados en cada distrito?

SELECT  DISTRITO, SUM(QRESIDUOS_MUN) AS [Residuos Municipales KG], SUM(POB_TOTAL) AS [Población]
FROM Residuos
GROUP BY DISTRITO

-- 2 ¿Cuál es la generación per cápita de residuos sólidos domiciliarios en cada departamento?

SELECT 
    DISTINCT DEPARTAMENTO,
    ROUND(SUM(QRESIDUOS_DOM),0) AS [Total Residuos Domiciliarios KG],
    SUM(POB_TOTAL) AS [Población],
    ROUND(SUM(QRESIDUOS_DOM) / SUM(POB_TOTAL),2) AS [Generación Per Capita / Persona]
FROM Residuos
GROUP BY DEPARTAMENTO
order by 4 DESC

-- 3 ¿Cuál es la región natural que genera la mayor cantidad de residuos no domiciliarios?

SELECT REG_NAT, ROUND(SUM(QRESIDUOS_NO_DOM),0)  AS [Residuos no Domiciliarios KG]
FROM Residuos
GROUP BY REG_NAT
ORDER BY 2 DESC




-- 4 ¿Cuál es la tendencia de la generación de residuos sólidos domiciliarios en Lima a lo largo de varios años?
SELECT  UBIGEO,DEPARTAMENTO,DISTRITO, PERIODO, ROUND(QRESIDUOS_DOM,0) AS [Total_Residuos_Domiciliarios KG], POB_TOTAL,N_SEC
FROM Residuos
WHERE DEPARTAMENTO = 'LIMA'
GROUP BY DEPARTAMENTO, PERIODO,POB_TOTAL,DISTRITO,QRESIDUOS_DOM,UBIGEO,N_SEC
ORDER BY DEPARTAMENTO, PERIODO, POB_TOTAL

-- 5 ¿Cuál es la tendencia de la generación de residuos sólidos domiciliarios en Lima y en el distrito de San Luis a lo largo de varios años?
SELECT 
DEPARTAMENTO,
DISTRITO, 
PERIODO, 
ROUND(QRESIDUOS_DOM,0) AS [Total_Residuos_Domiciliarios KG],
POB_TOTAL
FROM Residuos
WHERE DEPARTAMENTO = 'LIMA' and  UBIGEO = '150134' 
GROUP BY DEPARTAMENTO, PERIODO,POB_TOTAL,DISTRITO,QRESIDUOS_DOM
ORDER BY DEPARTAMENTO, PERIODO, POB_TOTAL DESC


-- Creación de vistas

-- Vista 1: Cantidad Total de Residuos Municipales por Distrito
CREATE VIEW Vista_ResiduosMunicipales AS
SELECT DISTRITO, SUM(QRESIDUOS_MUN) AS ResiduosMunicipalesKG, SUM(POB_TOTAL) AS Poblacion
FROM Residuos
GROUP BY DISTRITO;

-- Vista 2: Generación Per Cápita de Residuos Sólidos Domiciliarios por Departamento

CREATE VIEW Vista_GeneracionPerCapita AS
SELECT DISTINCT DEPARTAMENTO, 
    ROUND(SUM(QRESIDUOS_DOM), 0) AS TotalResiduosDomiciliariosKG, 
    SUM(POB_TOTAL) AS Poblacion,
    ROUND(SUM(QRESIDUOS_DOM) / SUM(POB_TOTAL), 2) AS GeneracionPerCapitaPorPersona
FROM Residuos
GROUP BY DEPARTAMENTO

-- Vista 3: Mayor Generación de Residuos No Domiciliarios por Región Natural

CREATE VIEW Vista_MayorGeneracionNoDomiciliarios AS
SELECT REG_NAT, ROUND(SUM(QRESIDUOS_NO_DOM), 0) AS ResiduosNoDomiciliariosKG
FROM Residuos
GROUP BY REG_NAT



-- Vista 4: Tendencia de Generación de Residuos Sólidos Domiciliarios en Lima a lo Largo de los Años

CREATE VIEW Vista_TendenciaResiduosLima AS
SELECT UBIGEO, DEPARTAMENTO, DISTRITO, PERIODO, ROUND(QRESIDUOS_DOM, 0) AS TotalResiduosDomiciliariosKG, POB_TOTAL, N_SEC
FROM Residuos
WHERE DEPARTAMENTO = 'LIMA'
GROUP BY DEPARTAMENTO, PERIODO, POB_TOTAL, DISTRITO, QRESIDUOS_DOM, UBIGEO, N_SEC

-- Vista 5: Tendencia de Generación de Residuos Sólidos Domiciliarios en Lima y el Distrito de San Luis a lo Largo de los Años

CREATE VIEW Vista_TendenciaResiduosSanLuis AS
SELECT DEPARTAMENTO, DISTRITO, PERIODO, ROUND(QRESIDUOS_DOM, 0) AS TotalResiduosDomiciliariosKG, POB_TOTAL
FROM Residuos
WHERE DEPARTAMENTO = 'LIMA' AND UBIGEO = '150134'
GROUP BY DEPARTAMENTO, PERIODO, POB_TOTAL, DISTRITO, QRESIDUOS_DOM

/* Seleccionar vista */

-- Vista 1: Cantidad Total de Residuos Municipales por Distrito

SELECT * FROM dbo.Vista_ResiduosMunicipales

-- Vista 2: Generación Per Cápita de Residuos Sólidos Domiciliarios por Departamento

SELECT * FROM dbo.Vista_GeneracionPerCapita

-- Vista 3: Mayor Generación de Residuos No Domiciliarios por Región Natural 

SELECT * FROM dbo.Vista_MayorGeneracionNoDomiciliarios


-- Vista 4: Tendencia de Generación de Residuos Sólidos Domiciliarios en Lima a lo Largo de los Años

SELECT * FROM dbo.Vista_TendenciaResiduosLima

-- Vista 5: Tendencia de Generación de Residuos Sólidos Domiciliarios en Lima y el Distrito de San Luis a lo Largo de los Años

SELECT * FROM dbo.Vista_TendenciaResiduosSanLuis

