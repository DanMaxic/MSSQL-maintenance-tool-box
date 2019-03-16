
 
 USE MM
 GO
 
 IF OBJECT_ID('Relp_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_TempArticleCollector
 GO
 
 
 SELECT  B.name AS PublicationName
        ,A.artid
        ,A.name AS ArticleName
        ,A.status
        ,C.srvname AS Subscriber
        ,A.filter_clause AS Filter
 INTO    dbo.Relp_TempArticleCollector
 FROM    dbo.sysarticles AS A
         INNER JOIN dbo.syspublications AS B
            ON A.pubid = B.pubid
         LEFT JOIN syssubscriptions AS C
            ON A.artid = C.artid
 ORDER BY PublicationName
        ,A.artid
GO   
   
 
 -----------------Create List Of Articles---------------

 USE MM
 GO
 
 IF OBJECT_ID('Relp_Distinct_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_Distinct_TempArticleCollector
 GO
 
 
 SELECT DISTINCT
         PublicationName
--,artid
        ,ArticleName
--,status
--,Subscriber
--,Filter
 INTO    dbo.Relp_Distinct_TempArticleCollector
 FROM    dbo.Relp_TempArticleCollector
 --WHERE  
 --status = 40
GO
 
 
 DECLARE @StringArticle VARCHAR(MAX)
  ,@PublicationName VARCHAR(80)
 
 SET @StringArticle = ''
 SET @PublicationName = 'MM'
 
 SELECT  @StringArticle = @StringArticle + ',''' + ArticleName + ''' '
 FROM    dbo.Relp_Distinct_TempArticleCollector
 WHERE   PublicationName = @PublicationName


----SELECT LEN(@StringArticle) 
SELECT @StringArticle = STUFF(@StringArticle,1,1,'')


 SELECT  @PublicationName AS 'PublicationName'
        ,@StringArticle AS 'ArtList'

GO




---------Delete Tables
 IF OBJECT_ID('Relp_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_TempArticleCollector
 GO
 IF OBJECT_ID('Relp_Distinct_TempArticleCollector') IS NOT NULL 
   DROP TABLE dbo.Relp_Distinct_TempArticleCollector  --Relp_Distinct_TempArticleCollector
 GO




/*
List Of Art per Pub:

 ,'App_CacheTypes'  ,'App_CacheVersions'  ,'App_CalibrationDataTypes'  ,'App_CalibrationStatuses'  ,'App_CalibrationTrancheStatuses'  ,'App_CalibrationTypes'  ,'App_Countries'  ,'App_CreditRatingAgencies'  ,'App_CreditRatings'  ,'App_CreditRatingTerms'  ,'App_EventDetails'  ,'App_EventDetailTypes'  ,'App_Events'  ,'App_EventTypes'  ,'App_GICSIndustries'  ,'App_GICSIndustryGroups'  ,'App_GICSSectors'  ,'App_GICSSubIndustries'  ,'App_IndexCalibrations'  ,'App_IndexConstituents'  ,'App_IndexConversions'  ,'App_InstrumentClasses'  ,'App_ISDAConventions'  ,'App_ISDADates'  ,'App_ISINs'  ,'App_IssuerConventions'  ,'App_IssuerCorporateActions'  ,'App_IssuerCorporateActionTypes'  ,'App_IssuerNames'  ,'App_IssuerNameTypes'  ,'App_IssuerRestructuringClauseConventions'  ,'App_PortfolioCalculationPortfolioStatuses'  ,'App_PortfolioCalculationStatuses'  ,'App_RecoveryModels'  ,'App_Regions'  ,'App_RollFrequencies'  ,'App_StandardRecoveryConventions'  ,'App_TrancheAdjustmentStatuses'  ,'App_TrancheCorrelations'  ,'Batch_IndexCalculationStatuses'  ,'CMA_Entities'  ,'CMA_FeedDataStatuses'  ,'CMA_FeedStatuses'  ,'CMA_FeedTypes'  ,'CMA_FileTypes'  ,'CMA_RestructuringClauses'  ,'CMA_Seniorities'  ,'Markit_IndexTypes'  ,'Markit_REDs'  ,'MD_AdjustedTrancheProviders'  ,'MD_AdjustedTranches'  ,'MD_BaseCorrelations'  ,'MD_CDSCurves'  ,'MD_CDSCurveStates'  ,'MD_CDSCurveTypes'  ,'MD_CDSSpreads'  ,'MD_CDSSpreads_Src'  ,'MD_Convention'  ,'MD_Currency'  ,'MD_CurrencyConfiguration'  ,'MD_CutoffTime'  ,'MD_DayCountConventions'  ,'MD_DeltaExchange'  ,'MD_DeltaExchange_Src'  ,'MD_Frequencies'  ,'MD_ImpliedCorrelations'  ,'MD_Index'  ,'MD_IndexFamilies'  ,'MD_IndexIssuer'  ,'MD_IndexLosses'  ,'MD_IndexSpread'  ,'MD_IndexTheoreticalValues'  ,'MD_IndexTranche'  ,'MD_IndexType'  ,'MD_IndexVersions'  ,'MD_IndexVersionTypes'  ,'MD_Issuer'  ,'MD_IssuerType'  ,'MD_Provider'  ,'MD_RecoveryRate'  ,'MD_RecoveryRates'  ,'MD_RecoveryRates_Src'  ,'MD_ReferenceTypes'  ,'MD_RestructuringClauseConversions'  ,'MD_RestructuringClauses'  ,'MD_Seniority'  ,'MD_Tenor'  ,'MD_TenorDurationType'  ,'MD_TradingStyles'  ,'MD_UpfrontFees'  ,'MD_UpfrontFees_Src'  ,'Reuters_Configuration'  ,'Reuters_RICs'  ,'User_ActivityDetailTypes'  ,'User_ActivityTypes'  ,'User_Basket'  ,'User_BasketItems'  ,'User_Contacts'  ,'User_Customization_ParamLookup'  ,'User_Customizations'  ,'User_CustomizationTypes'  ,'User_DataFolders'  ,'User_Features'  ,'User_GroupManagedIndices'  ,'User_Groups'  ,'User_GroupsFeatures'  ,'User_GroupsMainProviders'  ,'User_IndexApprovals'  ,'User_IndexDistributions'  ,'User_IndexDistributionStatuses'  ,'User_IndexPortfolios'  ,'User_Issuers'  ,'User_Notifications'  ,'User_PortfolioData'  ,'User_PortfolioDataTypes'  ,'User_Portfolios'  ,'User_PortfolioVersions'  ,'User_Session'  ,'User_TrancheStates'  ,'User_UsersGroups' 
'App_CacheTypes' ,'App_CacheVersions' ,'App_CalibrationDataTypes' ,'App_CalibrationStatuses' ,'App_CalibrationTrancheStatuses' ,'App_CalibrationTypes' ,'App_Countries' ,'App_CreditRatingAgencies' ,'App_CreditRatings' ,'App_CreditRatingTerms' ,'App_EventDetails' ,'App_EventDetailTypes' ,'App_Events' ,'App_EventTypes' ,'App_GICSIndustries' ,'App_GICSIndustryGroups' ,'App_GICSSectors' ,'App_GICSSubIndustries' ,'App_IndexCalibrations' ,'App_IndexConstituents' ,'App_IndexConversions' ,'App_InstrumentClasses' ,'App_ISDAConventions' ,'App_ISDADates' ,'App_ISINs' ,'App_IssuerConventions' ,'App_IssuerCorporateActions' ,'App_IssuerCorporateActionTypes' ,'App_IssuerNames' ,'App_IssuerNameTypes' ,'App_IssuerRestructuringClauseConventions' ,'App_PortfolioCalculationPortfolioStatuses' ,'App_PortfolioCalculationStatuses' ,'App_RecoveryModels' ,'App_Regions' ,'App_RollFrequencies' ,'App_StandardRecoveryConventions' ,'App_TrancheAdjustmentStatuses' ,'App_TrancheCorrelations' ,'Batch_IndexCalculationStatuses' ,'CMA_Entities' ,'CMA_FeedDataStatuses' ,'CMA_FeedStatuses' ,'CMA_FeedTypes' ,'CMA_FileTypes' ,'CMA_RestructuringClauses' ,'CMA_Seniorities' ,'Markit_IndexTypes' ,'Markit_REDs' ,'MD_AdjustedTrancheProviders' ,'MD_AdjustedTranches' ,'MD_BaseCorrelations' ,'MD_CDSCurves' ,'MD_CDSCurveStates' ,'MD_CDSCurveTypes' ,'MD_CDSSpreads' ,'MD_CDSSpreads_Src' ,'MD_Convention' ,'MD_Currency' ,'MD_CurrencyConfiguration' ,'MD_CutoffTime' ,'MD_DayCountConventions' ,'MD_DeltaExchange' ,'MD_DeltaExchange_Src' ,'MD_Frequencies' ,'MD_ImpliedCorrelations' ,'MD_Index' ,'MD_IndexFamilies' ,'MD_IndexIssuer' ,'MD_IndexLosses' ,'MD_IndexSpread' ,'MD_IndexTheoreticalValues' ,'MD_IndexTranche' ,'MD_IndexType' ,'MD_IndexVersions' ,'MD_IndexVersionTypes' ,'MD_Issuer' ,'MD_IssuerType' ,'MD_Provider' ,'MD_RecoveryRate' ,'MD_RecoveryRates' ,'MD_RecoveryRates_Src' ,'MD_ReferenceTypes' ,'MD_RestructuringClauseConversions' ,'MD_RestructuringClauses' ,'MD_Seniority' ,'MD_Tenor' ,'MD_TenorDurationType' ,'MD_TradingStyles' ,'MD_UpfrontFees' ,'MD_UpfrontFees_Src' ,'Reuters_Configuration' ,'Reuters_RICs' ,'User_ActivityDetailTypes' ,'User_ActivityTypes' ,'User_Basket' ,'User_BasketItems' ,'User_Contacts' ,'User_Customization_ParamLookup' ,'User_Customizations' ,'User_CustomizationTypes' ,'User_DataFolders' ,'User_Features' ,'User_GroupManagedIndices' ,'User_Groups' ,'User_GroupsFeatures' ,'User_GroupsMainProviders' ,'User_IndexApprovals' ,'User_IndexDistributions' ,'User_IndexDistributionStatuses' ,'User_IndexPortfolios' ,'User_Issuers' ,'User_Notifications' ,'User_PortfolioData' ,'User_PortfolioDataTypes' ,'User_Portfolios' ,'User_PortfolioVersions' ,'User_Session' ,'User_TrancheStates' ,'User_UsersGroups' 

*/

