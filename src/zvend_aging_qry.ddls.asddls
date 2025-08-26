@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Aging Rep Qry'

@Analytics.query: true
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [ #ANALYTICAL_QUERY ]
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVEND_AGING_QRY
  with parameters
    @Environment.systemField:#USER_DATE
    p_keydate : zdate,
    @EndUserText.label: 'Day1'
    @Consumption.defaultValue: '5'
    day1      : int4,
    @EndUserText.label: 'Day2'
    @Consumption.defaultValue: '10'
    day2      : int4,
    @EndUserText.label: 'Day3'
    @Consumption.defaultValue: '15'
    day3      : int4,
    @EndUserText.label: 'Day4'
    @Consumption.defaultValue: '20'
    day4      : int4,
    @EndUserText.label: 'Day5'
    @Consumption.defaultValue: '25'
    day5      : int4,
    @EndUserText.label: 'Day6'
    @Consumption.defaultValue: '30'
    day6      : int4,

    @EndUserText.label: 'Future Day1'
    @Consumption.defaultValue: '10'
    fday1     : int4,

    @EndUserText.label: 'Future Day2'
    @Consumption.defaultValue: '20'
    fday2     : int4

  as select distinct from ZVEND_AGING_CUBE( key_date : $parameters.p_keydate , day1 : $parameters.day1 , day2 : $parameters.day2 ,
                                  day3 : $parameters.day3 , day4 : $parameters.day4 , day5 : $parameters.day5 , day6 : $parameters.day6 ,
                                  fday1 : $parameters.fday1 , fday2 : $parameters.fday2  )
{


       @AnalyticsDetails.query.axis:#ROWS
       @EndUserText.label: 'Supplier'
       @Consumption.filter :{ selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
  key  Supplier,

       @EndUserText.label: 'Supplier Name'
       @AnalyticsDetails.query.axis:#ROWS
  key  SupplierName,

       @Consumption.filter :{ selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
       @AnalyticsDetails.query.axis:#ROWS
  key  FiscalYear,
       @Consumption.filter :{ selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
       @AnalyticsDetails.query.axis:#ROWS
  key  CCODE,

       @AnalyticsDetails.query.axis:#ROWS
       @Consumption.filter :{ selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
       @EndUserText.label: 'Accounting Document'
  key  AccountingDocument,

       @AnalyticsDetails.query.axis:#ROWS
       @EndUserText.label: 'Reference ID'
       @Consumption.filter :{ selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
  key  DocumentReferenceID,

       @Consumption.filter :{ selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
       @AnalyticsDetails.query.axis:#ROWS
       AccountingDocumentType,
       Zdays,
       CompanyCodeCurrency,
       OriginalReferenceDocument,
       PostingDate,
       NetDueDate,
       DocumentDate,
       SearchTerm1,
       SearchTerm2,
       TransactionCurrency,
       @EndUserText.label: 'Payment Terms'
       PaymentTerms,
       @EndUserText.label: 'Payment Terms Name'
       PaymentTermsName,
       @EndUserText.label: 'Account Group'
       SupplierAccountGroup,
       @EndUserText.label: 'Account Group Name'
       AccountGroupName,

       @DefaultAggregation: #SUM
       @EndUserText.label: 'AmountInTransactionCurrency'
       (AmountInTransactionCurrency) as AmountInTransactionCurrency,
       @DefaultAggregation: #SUM
       @EndUserText.label: 'AmountInCompanyCodeCurrency'
       (amt)                         as AmountInCompanyCodeCurrency,


       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : '0 - &1' ,
                                  binding : [ { index : 1, parameter : 'day1' } ] }
       (amt1)                        as amt1,

       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : '&1 - &2' ,
                                  binding : [ { index : 1, parameter : 'day1' } ,
                                   { index : 2, parameter : 'day2' }   ]     }
       (amt2)                        as amt2,

       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : '&2 - &3' ,
                                  binding : [ { index : 2, parameter : 'day2' } ,
                                   { index : 3, parameter : 'day3' }   ]     }
       (amt3)                        as amt3,

       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : '&3 - &4' ,
                                  binding : [ { index : 3, parameter : 'day3' } ,
                                   { index : 4, parameter : 'day4' }   ]     }
       (amt4)                        as amt4,

       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : '&4 - &5' ,
                                  binding : [ { index : 4, parameter : 'day5' } ,
                                              { index : 5, parameter : 'day5' }   ]  }
       (amt5)                        as amt5,

       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : '&5 - &6' ,
                                  binding : [ { index : 5, parameter : 'day5' } ,
                                              { index : 6, parameter : 'day6' }   ]  }
       (amt6)                        as amt6,



       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : 'Above &6' ,
                                  binding : [ { index : 6, parameter : 'day6' } ] }
       (above_amt6)                  as above_amt6,

       @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
       @DefaultAggregation: #SUM
       @EndUserText.label: 'Balance Amount'
       BalAmt,

       @DefaultAggregation: #SUM
       @Consumption.dynamicLabel: { label : 'Future Days < &1' ,
                                  binding : [ { index : 1, parameter : 'fday1' } ] }
       Fut_amt1                      as Fut_amt1,

       @Consumption.dynamicLabel: { label : 'Future Days &1 - &2' ,
                              binding : [ { index : 1, parameter : 'fday1' } ,
                               { index : 2, parameter : 'fday2' }   ]     }
       @DefaultAggregation: #SUM
       Fut_amt2                      as Fut_amt2,

       @Consumption.dynamicLabel: { label : 'Above Future Days &2' ,
                              binding : [   { index : 2, parameter : 'fday2' }   ]     }
       @DefaultAggregation: #SUM
       Fut_abov_amt2                 as Fut_abov_amt2


}
group by
  AccountingDocument,
  DocumentReferenceID,
  Supplier,
  SupplierName,
  FiscalYear,
  CCODE,
  AccountingDocumentType,
  Zdays,
  CompanyCodeCurrency,
  OriginalReferenceDocument,
  PostingDate,
  NetDueDate,
  DocumentDate,
  amt,
  amt1,
  amt2,
  amt3,
  amt4,
  amt5,
  amt6,
  above_amt6,
  BalAmt,
  Fut_amt1,
  Fut_amt2,
  Fut_abov_amt2,
  TransactionCurrency,
  SupplierAccountGroup,
  AmountInTransactionCurrency,
  AccountGroupName,
  SearchTerm1,
  SearchTerm2,
  PaymentTerms,
  PaymentTermsName
