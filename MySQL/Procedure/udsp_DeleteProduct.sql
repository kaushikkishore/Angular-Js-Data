/*									
Name		: udsp_DeleteWebWidget								
Description	: Deletes a Widget								
Author		: CRN								
									
Modification Log: Change									
---------------------------------------------------------------------------									
Description                  Date			Changed By						
Created procedure            23-Oct-14		CRN	
													
---------------------------------------------------------------------------									
Call	udsp_DeleteWebWidget
(
	'89cfd8cd976dbf5e135f7c23ea1b5e70ca167d24bf9c90bcc049c5aacda2e4c2',
	'fac4a531-5a82-11e4-8e7d-22000b500d7b'
)

*/									
									
DROP PROCEDURE IF EXISTS udsp_DeleteWebWidget;									
DELIMITER //									
CREATE PROCEDURE udsp_DeleteWebWidget									
(									
	var_AuthToken		varchar(1000),
	var_WidgetId		varchar(36)
)									
BEGIN									
	-- --------------------------------------------------------------------------
	-- #1 :: Declaration
	-- --------------------------------------------------------------------------
	DECLARE var_CallerUserId	VARCHAR(36);
	DECLARE var_IsCallerAdmin	BIT;
	DECLARE var_WidgetCreator	VARCHAR(36);

	DECLARE error_InvalidInputs CONDITION FOR SQLSTATE 'HY000';								
									
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL ;
	END;  

	-- --------------------------------------------------------------------------								
	-- #2 :: Variable Initialization								
	-- --------------------------------------------------------------------------								
	SET	var_WidgetId	= IFNULL(var_WidgetId,'');
	SET	var_AuthToken	= IFNULL(var_AuthToken,'');
	
	-- --------------------------------------------------------------------------								
	-- #3 :: Validation
	-- --------------------------------------------------------------------------		
	-- a) Mandatory Check
	IF(var_AuthToken = '' OR var_WidgetId = '') THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Mandatory Fields are not provided. `AuthToken` and `WidgetId` are mandatory.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;
		
	-- b) Token is correct - Check
	IF((SELECT COUNT(AuthToken) FROM User_Base WHERE AuthToken = var_AuthToken) <= 0) THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Incorrect AuthToken provided.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;
	
	-- c) UserTaskId is correct - Check
	IF((SELECT COUNT(WebWidgetId) FROM WebWidget_Base WHERE WebWidgetId = var_WidgetId) <= 0) THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Incorrect WidgetId  provided.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;

	-- d) OwnerId is same as CallerId - Check
	SELECT UserID, IsAdministrator INTO var_CallerUserId, var_IsCallerAdmin FROM User_Base      WHERE AuthToken = var_AuthToken;
	SELECT CreatedBy	           INTO var_WidgetCreator				    FROM WebWidget_Base WHERE WebWidgetId = var_WidgetId;

	IF (var_IsCallerAdmin <> 1) THEN
		IF((var_WidgetCreator <> var_CallerUserId) OR TRIM(IFNULL(var_CallerUserId,'')) = ''  AND TRIM(IFNULL(var_WidgetCreator,'')) = '')  THEN
			SIGNAL error_InvalidInputs								
			SET MESSAGE_TEXT    = 'Less Or No permission to perform this operation. Caller is not Widget Owner', 								
				MYSQL_ERRNO     = 2004;         								
		END IF;
	END IF;
								
	-- --------------------------------------------------------------------------								
	-- #4 :: Delete Record								
	-- --------------------------------------------------------------------------								
	START TRANSACTION;								
									
		DELETE	FROM WebWidget_Base WHERE WebWidgetId = var_WidgetId; 
		SELECT ROW_COUNT() INTO @var_RowsUpdated;

	COMMIT;
	
	SELECT @var_RowsUpdated AffectedRows;
									
END //									
DELIMITER ;									
