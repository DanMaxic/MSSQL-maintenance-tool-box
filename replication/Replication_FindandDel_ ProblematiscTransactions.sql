

-----Find and Delete problematisc transactions
USE distribution
GO
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @xact_seqno varbinary(16)
  ,@DeleteStatus BIT    -- 0 = Information only ; 1 = Excecuted Action

---SetInform or Execute mode.
-- 0 = Information only 
-- 1 = Excecuted Action
SET @DeleteStatus = 0

SET @xact_seqno = 0x0006247A000001C7000100000000 --0x0056A8A4000012A4000500000000
IF ( @DeleteStatus = 0 ) 
   BEGIN
      SELECT   @@SERVERNAME AS ServName
              ,'Select Status' AS ActionStatus

      SELECT   COUNT(*) AS Tran_CNT
      FROM     msrepl_transactions (NOLOCK)
      WHERE    xact_seqno = @xact_seqno

      SELECT   COUNT(*) AS Commants_CNT
      FROM     msrepl_commands (NOLOCK)
      WHERE    xact_seqno = @xact_seqno


      SELECT   *
      FROM     msrepl_transactions (NOLOCK)
      WHERE    xact_seqno = @xact_seqno



      SELECT   CAST(command AS NVARCHAR(4000)) AS Commands
      FROM     msrepl_commands (NOLOCK)
      WHERE    xact_seqno = @xact_seqno

   END ;

IF ( @DeleteStatus = 1 ) 
   BEGIN
      SELECT   @@SERVERNAME AS ServName
              ,'Delete Status' AS ActionStatus

      SELECT   COUNT(*) AS Tran_CNT
      FROM     msrepl_transactions (NOLOCK)
      WHERE    xact_seqno = @xact_seqno

      SELECT   COUNT(*) AS Commants_CNT
      FROM     msrepl_commands (NOLOCK)
      WHERE    xact_seqno = @xact_seqno

      SELECT   *
      FROM     msrepl_transactions (NOLOCK)
      WHERE    xact_seqno = @xact_seqno

      SELECT   CAST(command AS NVARCHAR(4000)) AS Commands
      FROM     msrepl_commands (NOLOCK)
      WHERE    xact_seqno = @xact_seqno

      DELETE   FROM msrepl_commands
      WHERE    xact_seqno = @xact_seqno

      DELETE   FROM msrepl_transactions
      WHERE    xact_seqno = @xact_seqno

   END ;

GO

