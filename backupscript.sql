USE [Course]
GO
ALTER TABLE [dbo].[Students] DROP CONSTRAINT [FK_Students_Class]
GO
ALTER TABLE [dbo].[Sele] DROP CONSTRAINT [FK_Sele_Students]
GO
ALTER TABLE [dbo].[Sele] DROP CONSTRAINT [FK_Sele_Course]
GO
ALTER TABLE [dbo].[Course] DROP CONSTRAINT [FK_Course_Teacher]
GO
ALTER TABLE [dbo].[Course] DROP CONSTRAINT [FK_Course_Round]
GO
ALTER TABLE [dbo].[Course] DROP CONSTRAINT [FK_Course_Category]
GO
ALTER TABLE [dbo].[Class] DROP CONSTRAINT [FK_Class_Grade]
GO
/****** Object:  Table [dbo].[Teacher]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Teacher]
GO
/****** Object:  Table [dbo].[Students]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Students]
GO
/****** Object:  Table [dbo].[Sele]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Sele]
GO
/****** Object:  Table [dbo].[Round]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Round]
GO
/****** Object:  Table [dbo].[Grade]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Grade]
GO
/****** Object:  Table [dbo].[Course]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Course]
GO
/****** Object:  Table [dbo].[Class]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Class]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 2013/7/10 10:54:01 ******/
DROP TABLE [dbo].[Category]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[ID] [int] NOT NULL,
	[Cname] [nvarchar](255) NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Class]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Class](
	[ID] [int] NOT NULL,
	[Cname] [nvarchar](255) NULL,
	[Gid] [int] NULL,
 CONSTRAINT [PK_Class] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Course]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course](
	[ID] [int] NOT NULL,
	[Cname] [nvarchar](255) NOT NULL,
	[MaxN] [int] NOT NULL,
	[MinN] [int] NOT NULL,
	[Rid] [int] NOT NULL,
	[Cid] [int] NOT NULL,
	[Gid] [int] NOT NULL,
	[Tid] [int] NOT NULL,
 CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Grade]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Grade](
	[ID] [int] NOT NULL,
	[Cname] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Grade] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Round]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Round](
	[ID] [int] NOT NULL,
	[Rname] [nvarchar](255) NOT NULL,
	[Seq] [int] NOT NULL,
 CONSTRAINT [PK_Round] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sele]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sele](
	[Sid] [int] NOT NULL,
	[Cid] [int] NOT NULL,
 CONSTRAINT [PK_Sele] PRIMARY KEY CLUSTERED 
(
	[Sid] ASC,
	[Cid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Students]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[ID] [int] NOT NULL,
	[sID] [nvarchar](255) NULL,
	[Sname] [nvarchar](255) NOT NULL,
	[Cid] [int] NOT NULL,
 CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Teacher]    Script Date: 2013/7/10 10:54:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teacher](
	[ID] [int] NOT NULL,
	[Cname] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Teacher] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_Grade] FOREIGN KEY([Gid])
REFERENCES [dbo].[Grade] ([ID])
GO
ALTER TABLE [dbo].[Class] CHECK CONSTRAINT [FK_Class_Grade]
GO
ALTER TABLE [dbo].[Course]  WITH CHECK ADD  CONSTRAINT [FK_Course_Category] FOREIGN KEY([Cid])
REFERENCES [dbo].[Category] ([ID])
GO
ALTER TABLE [dbo].[Course] CHECK CONSTRAINT [FK_Course_Category]
GO
ALTER TABLE [dbo].[Course]  WITH CHECK ADD  CONSTRAINT [FK_Course_Round] FOREIGN KEY([Rid])
REFERENCES [dbo].[Round] ([ID])
GO
ALTER TABLE [dbo].[Course] CHECK CONSTRAINT [FK_Course_Round]
GO
ALTER TABLE [dbo].[Course]  WITH CHECK ADD  CONSTRAINT [FK_Course_Teacher] FOREIGN KEY([Tid])
REFERENCES [dbo].[Teacher] ([ID])
GO
ALTER TABLE [dbo].[Course] CHECK CONSTRAINT [FK_Course_Teacher]
GO
ALTER TABLE [dbo].[Sele]  WITH CHECK ADD  CONSTRAINT [FK_Sele_Course] FOREIGN KEY([Cid])
REFERENCES [dbo].[Course] ([ID])
GO
ALTER TABLE [dbo].[Sele] CHECK CONSTRAINT [FK_Sele_Course]
GO
ALTER TABLE [dbo].[Sele]  WITH CHECK ADD  CONSTRAINT [FK_Sele_Students] FOREIGN KEY([Sid])
REFERENCES [dbo].[Students] ([ID])
GO
ALTER TABLE [dbo].[Sele] CHECK CONSTRAINT [FK_Sele_Students]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [FK_Students_Class] FOREIGN KEY([Cid])
REFERENCES [dbo].[Class] ([ID])
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [FK_Students_Class]
GO
