
CREATE DATABASE QhatuPeruNuevo
ON 
    PRIMARY (NAME = 'QhatuPeruNuevo_Data', FILENAME = 'C:\QhatuPeru\QhatuPeruNuevo.mdf'),
    FILEGROUP QhatuPeruNuevo_FG (NAME = 'QhatuPeruNuevo_Data_FG', FILENAME = 'C:\QhatuPeru\QhatuPeruNuevo_FG.ndf')
LOG ON 
    (NAME = 'QhatuPeruNuevo_Log', FILENAME = 'C:\QhatuPeru\QhatuPeruNuevo_Log.ldf');
GO
