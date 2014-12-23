/*									
Name		: udsp_DeleteProduct								
Description	: Deletes a Product								
Author		: Kaushik								
									
Modification Log: Change									
---------------------------------------------------------------------------									
Description                  Date			Changed By						
Created procedure            20-DEC-14		Kaushik	
													
---------------------------------------------------------------------------									
Call	udsp_DeleteProduct
(
	'89cfd8cd976dbf5e135f7c23ea1b5e70ca167d24bf9c90bcc049c5aacda2e4c2',
	'a3e5a5dd-882e-11e4-a71f-b888e3eaff25'
)

*/									
									
DROP PROCEDURE IF EXISTS udsp_DeleteProduct;									
DELIMITER //									
CREATE PROCEDURE udsp_DeleteProduct									
(									
	var_RequestorId		varchar(1000),
	var_ProductId		varchar(100)
)									
BEGIN									
	-- --------------------------------------------------------------------------
	-- #1 :: Declaration
	-- --------------------------------------------------------------------------
	DECLARE error_InvalidInputs CONDITION FOR SQLSTATE 'HY000';								
									
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL ;
	END;  

	-- --------------------------------------------------------------------------								
	-- #2 :: Variable Initialization								
	-- --------------------------------------------------------------------------								
	SET	var_ProductId	= IFNULL(var_ProductId,'');
	SET	var_RequestorId	= IFNULL(var_RequestorId,'');
	
	-- --------------------------------------------------------------------------								
	-- #3 :: Validation
	-- --------------------------------------------------------------------------		
	-- a) Mandatory Check
	IF(var_ProductId = '') THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Mandatory Field is not provided. `ProductId` is mandatory.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;
						
	-- --------------------------------------------------------------------------								
	-- #4 :: Delete Record								
	-- --------------------------------------------------------------------------								
	START TRANSACTION;								
									
		DELETE	FROM Product_Base WHERE ProductId = var_ProductId; 
		SELECT ROW_COUNT() INTO @var_RowsUpdated;

	COMMIT;
		
	SELECT @var_RowsUpdated AffectedRows;
									
END //									
DELIMITER ;									
