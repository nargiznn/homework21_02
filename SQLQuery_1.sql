CREATE DATABASE Course
USE Course
----Students və Groups table-larından ibarət db qurun (aralarında one-to-many relation var).
CREATE TABLE Students
(
    Id INT PRIMARY KEY IDENTITY,
    Fullname NVARCHAR(25),
    GroupId INT FOREIGN KEY REFERENCES Groups(Id)
)

CREATE TABLE Groups
(
 Id INT PRIMARY KEY,
 GroupNo INT
)
---INSERT groups (id groupno)
INSERT INTO Groups(Id,GroupNo)
VALUES
(1,101),
(2,202),
(3,303),
(4,404),
(5,505)

----INSERT  students(fullname,groupid)
INSERT INTO Students(Fullname,GroupId)
VALUES
(N'Hikmət Abbasov',1),
(N'Tofiq Quliyev',2),
(N'Nərmn Abbasova',4),
(N'Nəzrin Quluzadə',3),
(N'Elməddin Agazadə',1),
(N'Elmar Qarayev',3),
(N'Davud Əliyev',2)

---DELETEDSTUDENT (Id,Fullname,StudentID,GroupId,DeletedAt)
CREATE TABLE DeletedStudents
(
    Id INT PRIMARY KEY IDENTITY,
    Fullname NVARCHAR(25),
    StudentId INT,   
    GroupId INT,
    DeletedAT DATETIME2,
)

---Student datası silindikdə DeletedStudents table-na əlavə olsun avtomatik (trigger yazın)
CREATE TRIGGER TR_DeleteStudents ON dbo.Students
FOR DELETE 
AS 
INSERT INTO DeletedStudents(StudentId,Fullname,GroupId,DeletedAt)
SELECT D.Id,D.Fullname,D.GroupId,GETDATE()
FROM deleted AS D
JOIN Groups AS G ON G.Id=D.GroupId

----Delete eliyib yoxlamaq
SELECT *FROM Students
DELETE FROM Students WHERE GroupId=1
SELECT *FROM DeletedStudents

---Group datalarının IsDeleted column-u olsun və defauk false olsun.
ALTER TABLE Groups
ADD IsDeleted BIT NOT NULL DEFAULT 0

---Bir group datası silinmək istədikdə onun db-dan silinməsinin yerinə o 
---datanın IsDeleted dəyəri dəyişib true olsun (trigger yazın instead of ilə)

CREATE TRIGGER TR_insteadOfDelete_ ON dbo.Groups
INSTEAD OF DELETE 
AS 
INSERT INTO  DeletedStudents(StudentId,Fullname,GroupId,DeletedAt,isDeleted)
SELECT D.Id,D.Fullname,D.GroupId,GETDATE(),1
FROM deleted AS D
JOIN Groups AS G ON G.Id=D.GroupId

---NOT xeta verir