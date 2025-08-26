@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Aging Rep CUBE'

@Analytics.dataCategory: #CUBE
@ObjectModel.modelingPattern: #ANALYTICAL_CUBE
@ObjectModel.supportedCapabilities: [ #ANALYTICAL_PROVIDER, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE ]

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVEND_AGING_CUBE
  with parameters

    key_date : vdm_v_key_date,
    day1     : int4,
    day2     : int4,
    day3     : int4,
    day4     : int4,
    day5     : int4,
    day6     : int4,
    fday1    : int4,
    fday2    : int4

  as select distinct from ZVEND_AGING_CDS ( key_date : $parameters.key_date , day1 : $parameters.day1 , day2 : $parameters.day2 ,
                                           day3 : $parameters.day3 , day4 : $parameters.day4 , day5 : $parameters.day5 , day6 : $parameters.day6 ,
                                            fday1 : $parameters.fday1 , fday2 : $parameters.fday2  ) as a
{
  key a.AccountingDocument,
  key a.DocumentReferenceID,
  key a.Supplier,
  key a.SupplierName,
      a.FiscalYear,
      a.CCODE,
      a.NetDueDate,
      a.PostingDate,
      a.DocumentDate,
      a.AccountingDocumentType,
      a.Zdays,
      a.CompanyCodeCurrency,
      a.TransactionCurrency,
      a.SupplierAccountGroup,
      a.AccountGroupName,
      a.SearchTerm1,
      a.SearchTerm2,
      a.PaymentTerms,
      a.PaymentTermsName,
      a.OriginalReferenceDocument,
      a.AmountInTransactionCurrency,
      sum( a.amt )                                                                     as amt,

      case when
      a.Zdays <= $parameters.day1  and $parameters.key_date >= a.NetDueDate
      then a.amt
      else null
      end                                                                              as amt1,

      case when
       a.Zdays > $parameters.day1 and
       a.Zdays <= $parameters.day2 and $parameters.key_date >= a.NetDueDate
       then  a.amt
       else null
       end                                                                             as amt2,
      case when
      a.Zdays > $parameters.day2 and
      a.Zdays <= $parameters.day3 and $parameters.key_date >= a.NetDueDate
      then  a.amt
      else null
      end                                                                              as amt3,

      case when
      a.Zdays > $parameters.day3 and
      a.Zdays <= $parameters.day4 and $parameters.key_date >= a.NetDueDate
      then a.amt
      else null
      end                                                                              as amt4,

      case when
      a.Zdays > $parameters.day4 and
      a.Zdays <= $parameters.day5 and $parameters.key_date >= a.NetDueDate
      then  a.amt
      else null
      end                                                                              as amt5,

      case when
      a.Zdays > $parameters.day5 and
      a.Zdays <= $parameters.day6 and $parameters.key_date >= a.NetDueDate
      then  a.amt
      else null
      end                                                                              as amt6,


      case when
      a.Zdays > $parameters.day6 and $parameters.key_date >= a.NetDueDate
      then a.amt
      else null
      end                                                                              as above_amt6,

      cast( coalesce( a.amt , 0 ) + coalesce( a.clearedamt, 0 ) as abap.dec( 20, 2 ) ) as BalAmt,


      case when
      a.Zdays <= $parameters.fday1 and $parameters.key_date < a.NetDueDate
      then a.amt
      else null
      end                                                                              as Fut_amt1,

      case when
      a.Zdays > $parameters.fday1 and
      a.Zdays <= $parameters.fday2
      then  a.amt
      else null
      end                                                                              as Fut_amt2,

      case when
      a.Zdays > $parameters.fday2
      then a.amt
      else null
      end                                                                              as Fut_abov_amt2





}
group by
  a.AccountingDocument,
  a.DocumentReferenceID,
  a.Supplier,
  a.SupplierName,
  a.FiscalYear,
  a.CCODE,
  a.NetDueDate,
  a.PostingDate,
  a.DocumentDate,
  a.AccountingDocumentType,
  a.Zdays,
  a.CompanyCodeCurrency,
  a.AmountInTransactionCurrency,
  a.TransactionCurrency,
  a.SupplierAccountGroup,
  a.AccountGroupName,
  a.OriginalReferenceDocument,
  a.clearedamt,
  a.amt,
  a.SearchTerm1,
  a.SearchTerm2,
  a.PaymentTerms,
  a.PaymentTermsName
