@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Aging Rep CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVEND_AGING_CDS
  with parameters

    @Environment.systemField:#USER_DATE
    key_date : vdm_v_key_date,

    day1     : int4,
    day2     : int4,
    day3     : int4,
    day4     : int4,
    day5     : int4,
    day6     : int4,
    fday1    : int4,
    fday2    : int4


  as select distinct from I_OperationalAcctgDocItem                     as a
    left outer join       I_Supplier                                    as b on b.Supplier = a.Supplier
    inner join            I_JournalEntry                                as c on(
      c.AccountingDocument = a.AccountingDocument
      and c.FiscalYear     = a.FiscalYear
      and c.CompanyCode    = a.CompanyCode
    )
    left outer join       ZBAL_AMOUNT( key_date: $parameters.key_date ) as e on(
      e.InvoiceReference               = a.AccountingDocument
      and e.InvoiceReferenceFiscalYear = a.FiscalYear
      and e.CompanyCode                = a.CompanyCode

    )
    left outer join       I_PaymentTermsText                            as p on(
      p.PaymentTerms = a.PaymentTerms
      and p.Language = 'E'
    )

{
  key   a.AccountingDocument,
  key   c.DocumentReferenceID,
  key   a.Supplier,
  key   b.SupplierName,
        a.AccountingDocumentType,
        a.FiscalYear,
        a.CompanyCode                                                  as CCODE,
        a.NetDueDate,
        a.PostingDate,
        a.DocumentDate,
        a.InvoiceReference,
        a.PaymentTerms,
        p.PaymentTermsDescription ,
        p.PaymentTermsName ,
        left( a.OriginalReferenceDocument, 10 )                        as OriginalReferenceDocument,

        a.CompanyCodeCurrency,
        a.TransactionCurrency,
        b.SupplierAccountGroup,
        b._SupplierAccountGroupText[ Language = 'E' ].AccountGroupName as AccountGroupName,


        dats_days_between( a.PostingDate ,$parameters.key_date )       as Zdays,

        dats_days_between( $parameters.key_date , a.NetDueDate )       as NETDAYS,


        cast(a.AmountInCompanyCodeCurrency  as abap.dec( 20, 2 ) )     as amt,
        cast(e.clearedamt  as abap.dec( 20, 2 ) )                      as clearedamt,

        cast(a.AmountInTransactionCurrency  as abap.dec( 20, 2 ) )     as AmountInTransactionCurrency,

        b._AddressRepresentation.AddressSearchTerm1                    as SearchTerm1,
        b._AddressRepresentation.AddressSearchTerm2                    as SearchTerm2

}
where
          a.FinancialAccountType       =  'K'
  and     c.IsReversal                 =  ''
  and     c.IsReversed                 =  ''
  and     a.SpecialGLCode              <> 'F'
  and(
          a.ClearingAccountingDocument =  ''
    or    a.ClearingDate               > $parameters.key_date
  )

  and     a.PostingDate                <= $parameters.key_date
  and(
    (
          a.AccountingDocumentType     <> 'KZ'
      and a.AccountingDocumentType     <> 'SA'
    )
    or    a.InvoiceReference           is initial
  )

//  and a.InvoiceReference           is initial
