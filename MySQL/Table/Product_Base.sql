CREATE	TABLE IF NOT EXISTS Product_Base
(
	ProductId							VARCHAR(36)		NOT NULL 						,
	ProductAutoId					    INT				NOT NULL AUTO_INCREMENT UNIQUE 	,
	Name								NVARCHAR(100)									,

	Code								VARCHAR(36)		 								, 
	Description							TEXT			CHARACTER SET UTF8				, 
	ReleaseDate							DATETIME										,
	
	StatusCode							INT				NOT NULL DEFAULT 0				,
	StatusReason						INT				NOT NULL DEFAULT 0				,
	
	Cost								NVARCHAR(100)									,
	Price								NVARCHAR(100)									,
	Category							VARCHAR(255)									,
	
	Tag									NVARCHAR(255)									,
	ImageUrl           					NVARCHAR(255)									,	
	CreatedOn							DATETIME		NOT NULL						,
	ModifiedOn							DATETIME		NOT NULL						,

	CONSTRAINT 	PK_Product_Base_ProductId			PRIMARY KEY	(ProductId)
);