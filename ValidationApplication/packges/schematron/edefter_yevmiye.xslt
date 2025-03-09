<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:defterek="http://www.edefter.gov.tr/ek"
                xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                xmlns:edefter="http://www.edefter.gov.tr"
                xmlns:gl-bus="http://www.xbrl.org/int/gl/bus/2006-10-25"
                xmlns:gl-cor="http://www.xbrl.org/int/gl/cor/2006-10-25"
                xmlns:gl-muc="http://www.xbrl.org/int/gl/muc/2006-10-25"
                xmlns:gl-plt="http://www.xbrl.org/int/gl/plt/2010-04-16"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:xades="http://uri.etsi.org/01903/v1.3.2#"
                xmlns:xbrli="http://www.xbrl.org/2003/instance"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=/">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=/">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <xsl:apply-templates select="/" mode="M17"/>
      <xsl:apply-templates select="/" mode="M18"/>
      <xsl:apply-templates select="/" mode="M19"/>
      <xsl:apply-templates select="/" mode="M20"/>
      <xsl:apply-templates select="/" mode="M21"/>
      <xsl:apply-templates select="/" mode="M22"/>
      <xsl:apply-templates select="/" mode="M23"/>
      <xsl:apply-templates select="/" mode="M24"/>
      <xsl:apply-templates select="/" mode="M25"/>
      <xsl:apply-templates select="/" mode="M26"/>
      <xsl:apply-templates select="/" mode="M27"/>
      <xsl:apply-templates select="/" mode="M28"/>
      <xsl:apply-templates select="/" mode="M29"/>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <xsl:param name="periodCoveredStart"
              select="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo/gl-cor:periodCoveredStart"/>
   <xsl:param name="periodCoveredEnd"
              select="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo/gl-cor:periodCoveredEnd"/>
   <xsl:param name="vknTckn"
              select="/edefter:defter/xbrli:xbrl/xbrli:context/xbrli:entity/xbrli:identifier"/>
   <xsl:param name="donemYil" select="substring($periodCoveredStart,1,4)"/>
   <xsl:param name="donemAy" select="substring($periodCoveredStart,6,2)"/>
   <xsl:param name="donem" select="number(concat($donemYil,$donemAy))"/>
   <xsl:param name="dosyaAdi" select="base-uri()"/>
   <!--PATTERN kok-->
   <!--RULE -->
   <xsl:template match="*" priority="1001" mode="M17">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@decimals) or  @decimals = 'INF'"/>
         <xsl:otherwise>Belge içerisindeki 'decimals' nitelikleri 'INF' değerini almalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/" priority="1000" mode="M17">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="edefter:defter"/>
         <xsl:otherwise>Yevmiye defteri dokumanı edefter:defter ana elemanı ile başlamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <!--PATTERN entity-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/xbrli:context/xbrli:entity"
                 priority="1000"
                 mode="M18">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(xbrli:segment/gl-bus:numberOfEntries)"/>
         <xsl:otherwise> xbrli:segment/gl-bus:numberOfEntries elemanı sadece yevmiye beratında bulunabilir.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(xbrli:segment/gl-cor:uniqueID)"/>
         <xsl:otherwise>xbrli:segment/gl-cor:uniqueID elemanı sadece beratlarda bulunabilir.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="contains($dosyaAdi,concat(xbrli:identifier,'-'))"/>
         <xsl:otherwise>Dosya adına yazılan vkn/tckn ile xbrli:identifier elemanına yazılan vkn/tckn aynı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
   <!--PATTERN defter-->
   <!--RULE -->
   <xsl:template match="/edefter:defter" priority="1000" mode="M19">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ds:Signature"/>
         <xsl:otherwise>ds:Signature zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
   </xsl:template>
   <!--PATTERN signature-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/ds:Signature" priority="1002" mode="M20">
      <xsl:variable name="signatureMethodAlgorithm"
                    select="ds:SignedInfo/ds:SignatureMethod/@Algorithm"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ds:SignedInfo/ds:Reference/ds:Transforms"/>
         <xsl:otherwise>ds:SignedInfo/ds:Reference/ds:Transforms elemanı zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ds:KeyInfo"/>
         <xsl:otherwise>ds:KeyInfo elemanı zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(ds:KeyInfo) or ds:KeyInfo/ds:X509Data"/>
         <xsl:otherwise>ds:KeyInfo elemanı içerisindeki ds:X509Data elemanı zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ds:Object"/>
         <xsl:otherwise>ds:Object elemanı zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(ds:Object) or ds:Object/xades:QualifyingProperties/xades:SignedProperties/xades:SignedSignatureProperties/xades:SigningTime"/>
         <xsl:otherwise>xades:SigningTime elemanı zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(ds:Object) or ds:Object/xades:QualifyingProperties/xades:SignedProperties/xades:SignedSignatureProperties/xades:SigningCertificate"/>
         <xsl:otherwise>xades:SigningCertificate elemanı zorunlu bir elemandır<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(ds:SignedInfo/ds:Reference[@URI = '']) = 1 "/>
         <xsl:otherwise>ds:SignedInfo elamanı içerisinde URI niteliği boşluğa("") eşit olan sadece bir tane ds:Reference elemanının bulunmaldır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(ends-with($signatureMethodAlgorithm,'sha1'))"/>
         <xsl:otherwise>İmzalama işleminde kullanılacak özet(hash) algoritması sha1 olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/ds:Signature/ds:KeyInfo/ds:X509Data"
                 priority="1001"
                 mode="M20">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ds:X509Certificate"/>
         <xsl:otherwise>ds:X509Data elemanı içerisindeki ds:X509Certificate elemanı zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/ds:Signature/ds:KeyInfo/ds:X509Data/ds:X509SubjectName"
                 priority="1000"
                 mode="M20">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) != 0 "/>
         <xsl:otherwise> ds:X509SubjectName elemanının değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
   </xsl:template>
   <!--PATTERN xbrl-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl" priority="1001" mode="M21">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(xbrli:context) = 1 "/>
         <xsl:otherwise>xbrli:context zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(xbrli:unit) &gt;= 1 "/>
         <xsl:otherwise>xbrli:unit zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(gl-cor:accountingEntries) = 1 "/>
         <xsl:otherwise>gl-cor:accountingEntries zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(xbrli:unit/xbrli:measure) &gt;= 1 "/>
         <xsl:otherwise>xbrli:measure zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(xbrli:unit/xbrli:measure[starts-with(normalize-space(.),'iso4217:')]) &gt;=1 "/>
         <xsl:otherwise>iso4217 kod listesindeki değerlerden birini içeren en az 1 measure değeri bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/xbrli:context/xbrli:entity/xbrli:identifier"
                 priority="1000"
                 mode="M21">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.) , '^[0-9]{10,11}$')"/>
         <xsl:otherwise>xbrli:identifier elemanına 10 haneli vergi kimlik numarası ve ya 11 haneli TC kimlik numarası yazılmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
   </xsl:template>
   <!--PATTERN measure-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/xbrli:unit/xbrli:measure"
                 priority="1000"
                 mode="M22">
      <xsl:variable name="currency" select="substring(.,9)"/>
      <xsl:variable name="currencyCodeList"
                    select="',AED,AFN,ALL,AMD,ANG,AOA,ARS,AUD,AWG,AZN,BAM,BBD,BDT,BGN,BHD,BIF,BMD,BND,BOB,BOV,BRL,BSD,BTN,BWP,BYN,BYR,BZD,CAD,CDF,CHE,CHF,CHW,CLF,CLP,CNY,COP,COU,CRC,CUC,CUP,CVE,CZK,DJF,DKK,DOP,DZD,EEK,EGP,ERN,ETB,EUR,FJD,FKP,GBP,GEL,GHS,GIP,GMD,GNF,GTQ,GWP,GYD,HKD,HNL,HRK,HTG,HUF,IDR,ILS,INR,IQD,IRR,ISK,JMD,JOD,JPY,KES,KGS,KHR,KMF,KPW,KRW,KWD,KYD,KZT,LAK,LBP,LKR,LRD,LSL,LTL,LVL,LYD,MAD,MAD,MDL,MGA,MKD,MMK,MNT,MOP,MRO,MUR,MVR,MWK,MXN,MXV,MYR,MZN,NAD,NGN,NIO,NOK,NPR,NZD,OMR,PAB,PEN,PGK,PHP,PKR,PLN,PYG,QAR,RON,RSD,RUB,RWF,SAR,SBD,SCR,SDG,SEK,SGD,SHP,SLL,SOS,SSP,SRD,STD,SVC,SYP,SZL,THB,TJS,TMT,TND,TOP,TRY,TTD,TWD,TZS,UAH,UGX,USD,USN,USS,UYI,UYU,UZS,VEF,VND,VUV,WST,XAF,XAG,XAU,XBA,XBB,XBC,XBD,XCD,XDR,XFU,XOF,XPD,XPF,XPT,XSU,XTS,XUA,XXX,YER,ZAR,ZMK,ZMW,ZWL,'"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not (starts-with(normalize-space(.),'iso4217:')) or contains($currencyCodeList, concat(',',$currency,','))"/>
         <xsl:otherwise>Gecersiz currency degeri: '<xsl:text/>
            <xsl:value-of select="$currency"/>
            <xsl:text/>'.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(parent::node()[contains($currencyCodeList, @id)]) &lt;=1 "/>
         <xsl:otherwise>id'si iso4217 multicurrency kodlarından birisi olan en fazla 1 xbrli:unit elemanı olabilir. <xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(parent::node()[contains($currencyCodeList,@id)]) or  .= concat('iso4217:',parent::node()/@id) "/>
         <xsl:otherwise>xbrli:measure değeri (<xsl:text/>
            <xsl:value-of select="."/>
            <xsl:text/>) hatalıdır. xbrli:unit id'nin değeri <xsl:text/>
            <xsl:value-of select="parent::node()/@id"/>
            <xsl:text/> olduğu için xbrli:measure değeri <xsl:text/>
            <xsl:value-of select="concat('iso4217:',parent::node()/@id)"/>
            <xsl:text/> olmalıdır. <xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(parent::node()[contains($currencyCodeList,@id)]) or  not(/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo/gl-muc:defaultCurrency) or not(.= concat('iso4217:',parent::node()/@id)) or /edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo/gl-muc:defaultCurrency=."/>
         <xsl:otherwise> gl-muc:defaultCurrency değeri (<xsl:text/>
            <xsl:value-of select="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo/gl-muc:defaultCurrency"/>
            <xsl:text/>) hatalıdır. gl-muc:defaultCurrency elemanı varsa değeri xbrli:measure(<xsl:text/>
            <xsl:value-of select="."/>
            <xsl:text/>) ile aynı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <!--PATTERN accountingentries-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries"
                 priority="1000"
                 mode="M23">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:documentInfo"/>
         <xsl:otherwise>gl-cor:documentInfo zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:entityInformation"/>
         <xsl:otherwise>gl-cor:entityInformation zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="entryHeaderSayisi" select="count(gl-cor:entryHeader)"/>
      <xsl:variable name="dosyaAdi" select="base-uri(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(contains($dosyaAdi,'Y-000000')) or ($entryHeaderSayisi &gt; 0)"/>
         <xsl:otherwise>Tüm ayı kapsayan bir defterde en az 1 gl-cor:entryHeader elemanı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <!--PATTERN documentinfo-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo"
                 priority="1000"
                 mode="M24">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:entriesType"/>
         <xsl:otherwise>gl-cor:entriesType zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="normalize-space(gl-cor:entriesType) = 'journal'"/>
         <xsl:otherwise>gl-cor:entriesType elemanı yevmiye defteri için 'journal' değerini almalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:uniqueID"/>
         <xsl:otherwise>gl-cor:uniqueID zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:uniqueID) or starts-with(normalize-space(gl-cor:uniqueID),'YEV')"/>
         <xsl:otherwise>gl-cor:uniqueID elemanı yevmiye defteri için 'YEV' değeri ile başlamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:uniqueID) or string-length(normalize-space(gl-cor:uniqueID)) = 15"/>
         <xsl:otherwise>gl-cor:uniqueID elemanı 15 karakterden oluşmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:creationDate"/>
         <xsl:otherwise>gl-cor:creationDate zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:periodCoveredStart"/>
         <xsl:otherwise>gl-cor:periodCoveredStart zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:periodCoveredEnd"/>
         <xsl:otherwise>gl-cor:periodCoveredEnd zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:periodCoveredEnd &gt;= gl-cor:periodCoveredStart"/>
         <xsl:otherwise>gl-cor:periodCoveredEnd elemanı gl-cor:periodCoveredStart elemanından büyük ve ya eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:creationDate &gt;= gl-cor:periodCoveredEnd"/>
         <xsl:otherwise>gl-cor:creationDate elemanı gl-cor:periodCoveredEnd elemanından büyük veya eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(gl-bus:sourceApplication)) &gt; 0"/>
         <xsl:otherwise>gl-bus:sourceApplication zorunlu bir elemandır ve değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="contains($dosyaAdi,concat('-',$donem,'-'))"/>
         <xsl:otherwise>Dosya adındaki dönem ile periodCoveredStart'daki dönem bilgisi aynı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="donemYilPrdEnd" select="substring(gl-cor:periodCoveredEnd,1,4)"/>
      <xsl:variable name="donemAyPrdEnd" select="substring(gl-cor:periodCoveredEnd,6,2)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$donemYil=$donemYilPrdEnd"/>
         <xsl:otherwise>gl-cor:periodCoveredStart elemanındaki yıl bilgisi ile periodCoveredEnd elemanındaki yıl bilgisi aynı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$donemAy=$donemAyPrdEnd"/>
         <xsl:otherwise>gl-cor:periodCoveredStart elemanındaki ay bilgisi ile periodCoveredEnd elemanındaki ay bilgisi aynı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="contains(gl-cor:uniqueID,concat($donemYil,$donemAy))"/>
         <xsl:otherwise>gl-cor:uniqueID elemanındaki dönem bilgisi ile gl-cor:periodCoveredStart elemanındaki dönem bilgisi aynı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>
   <!--PATTERN entityinformation-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entityInformation"
                 priority="1004"
                 mode="M25">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:entityPhoneNumber"/>
         <xsl:otherwise>gl-bus:entityPhoneNumber zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:entityEmailAddressStructure"/>
         <xsl:otherwise>gl-bus:entityEmailAddressStructure zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(gl-bus:organizationIdentifiers) &gt;= 1"/>
         <xsl:otherwise>gl-bus:organizationIdentifiers zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(string-length($vknTckn) = 10) or count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Kurum Unvanı']) = 1"/>
         <xsl:otherwise>gl-bus:organizationDescription değeri 'Kurum Unvanı' olan bir tane gl-bus:organizationIdentifiers elemanı bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(string-length($vknTckn) = 11) or count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Adı Soyadı']) = 1"/>
         <xsl:otherwise>gl-bus:organizationDescription değeri 'Adı Soyadı' olan bir tane gl-bus:organizationIdentifiers elemanı bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="countKurumUnvani"
                    select="count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Kurum Unvanı'])"/>
      <xsl:variable name="countAdiSoyadi"
                    select="count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Adı Soyadı'])"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="($countKurumUnvani=1 and not($countAdiSoyadi=1)) or ($countAdiSoyadi=1 and not($countKurumUnvani=1))"/>
         <xsl:otherwise>gl-bus:organizationDescription değeri 'Kurum Unvanı' veya 'Adı Soyadı' olan yalnızca bir tane gl-bus:organizationIdentifiers elemanı bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Kurum Unvanı']) = 1) or      string-length(normalize-space(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Kurum Unvanı']/gl-bus:organizationIdentifier)) &gt;=2"/>
         <xsl:otherwise>gl-bus:organizationDescription değeri 'Kurum Unvanı' olan gl-bus:organizationIdentifiers elemanının  gl-bus:organizationIdentifier eleman değeri en az iki karakter olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Adı Soyadı']) = 1) or      string-length(normalize-space(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Adı Soyadı']/gl-bus:organizationIdentifier)) &gt;=2"/>
         <xsl:otherwise>gl-bus:organizationDescription değeri 'Adı Soyadı' olan gl-bus:organizationIdentifiers elemanının  gl-bus:organizationIdentifier eleman değeri en az iki karakter olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="countSubeNo"
                    select="count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Şube No'])"/>
      <xsl:variable name="countSubeAdi"
                    select="count(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Şube Adı'])"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(not($countSubeNo = 1) or $countSubeAdi = 1) and (not($countSubeAdi = 1) or $countSubeNo = 1)"/>
         <xsl:otherwise>Şube no ve şube adı birlikte bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="($countSubeNo &lt; 2) and ($countSubeAdi &lt; 2)"/>
         <xsl:otherwise>Şube no veya şube adı birden fazla olamaz.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($countSubeNo = 1) or matches(normalize-space(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Şube No']/gl-bus:organizationIdentifier) , '^[0-9]{4}$')"/>
         <xsl:otherwise>Şube no 4 haneli sayısal bir değer olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($countSubeAdi = 1) or string-length(normalize-space(gl-bus:organizationIdentifiers[gl-bus:organizationDescription = 'Şube Adı']/gl-bus:organizationIdentifier)) &gt;= 2"/>
         <xsl:otherwise>Şube adı değeri en az iki karakter olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:organizationAddress"/>
         <xsl:otherwise>gl-bus:organizationAddress zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-bus:organizationAddress) or gl-bus:organizationAddress/gl-bus:organizationBuildingNumber"/>
         <xsl:otherwise>gl-bus:organizationAddress elemanı içerisindeki gl-bus:organizationBuildingNumber zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-bus:organizationAddress) or gl-bus:organizationAddress/gl-bus:organizationAddressStreet"/>
         <xsl:otherwise>gl-bus:organizationAddress elemanı içerisindeki gl-bus:organizationAddressStreet zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-bus:organizationAddress) or gl-bus:organizationAddress/gl-bus:organizationAddressCity"/>
         <xsl:otherwise>gl-bus:organizationAddress elemanı içerisindeki gl-bus:organizationAddressCity zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-bus:organizationAddress) or gl-bus:organizationAddress/gl-bus:organizationAddressZipOrPostalCode"/>
         <xsl:otherwise>gl-bus:organizationAddress' elemanı içerisindeki 'gl-bus:organizationAddressZipOrPostalCode zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-bus:organizationAddress) or gl-bus:organizationAddress/gl-bus:organizationAddressCountry"/>
         <xsl:otherwise>gl-bus:organizationAddress elemanı içerisindeki gl-bus:organizationAddressCountry zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:entityWebSite"/>
         <xsl:otherwise>gl-bus:entityWebSite zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(gl-bus:businessDescription)) &gt; 0"/>
         <xsl:otherwise>gl-bus:businessDescription zorunlu bir elemandır ve değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:fiscalYearStart"/>
         <xsl:otherwise>gl-bus:fiscalYearStart zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:fiscalYearEnd"/>
         <xsl:otherwise>gl-bus:fiscalYearEnd zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:fiscalYearEnd &gt; gl-bus:fiscalYearStart"/>
         <xsl:otherwise>gl-bus:fiscalYearEnd elemanı gl-bus:fiscalYearStart elemanından büyük olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:accountantInformation"/>
         <xsl:otherwise>gl-bus:accountantInformation zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entityInformation/gl-bus:accountantInformation"
                 priority="1003"
                 mode="M25">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(gl-bus:accountantName)) &gt; 0"/>
         <xsl:otherwise>gl-bus:accountantInformation elemanı içerisindeki gl-bus:accountantName zorunlu bir elemandır ve değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(gl-bus:accountantEngagementTypeDescription)) &gt; 0"/>
         <xsl:otherwise>gl-bus:accountantInformation elemanı içerisindeki gl-bus:accountantEngagementTypeDescription zorunlu bir elemandır  ve değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entityInformation/gl-bus:entityPhoneNumber"
                 priority="1002"
                 mode="M25">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(gl-bus:phoneNumber)) &gt; 0"/>
         <xsl:otherwise>gl-bus:phoneNumber zorunlu bir elemandır ve değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entityInformation/gl-bus:entityEmailAddressStructure"
                 priority="1001"
                 mode="M25">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(gl-bus:entityEmailAddress)) &gt; 0"/>
         <xsl:otherwise>gl-bus:entityEmailAddressStructure elemanı içerisinde gl-bus:entityEmailAddress zorunlu bir elemandır ve  ve değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entityInformation/gl-bus:entityWebSite"
                 priority="1000"
                 mode="M25">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:webSiteURL"/>
         <xsl:otherwise>gl-bus:entityWebSite elemanı içerisindeki gl-bus:webSiteURL zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <!--PATTERN entryheader-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entryHeader"
                 priority="1000"
                 mode="M26">

      <!--ASSERT -->

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(following::node()) or not(following::node()/gl-cor:enteredDate) or not(gl-cor:enteredDate) or following::node()/gl-cor:enteredDate &gt;= gl-cor:enteredDate"/>
         <xsl:otherwise>Yevmiye defteri tarihe göre sıralı olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:enteredBy"/>
         <xsl:otherwise>gl-cor:enteredBy zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:enteredBy) or string-length(normalize-space(gl-cor:enteredBy)) &gt;= 2"/>
         <xsl:otherwise>gl-cor:enteredBy elemanı en az iki karakter olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:enteredDate"/>
         <xsl:otherwise>gl-cor:enteredDate zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:enteredDate) or (gl-cor:enteredDate &gt;= $periodCoveredStart and gl-cor:enteredDate &lt;= $periodCoveredEnd)"/>
         <xsl:otherwise>gl-cor:enteredDate elemanın değeri <xsl:text/>
            <xsl:value-of select="$periodCoveredStart"/>
            <xsl:text/> ile <xsl:text/>
            <xsl:value-of select="$periodCoveredEnd"/>
            <xsl:text/> değerleri arasında olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:totalDebit"/>
         <xsl:otherwise>gl-bus:totalDebit zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:totalCredit"/>
         <xsl:otherwise>gl-bus:totalCredit zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:entryNumberCounter"/>
         <xsl:otherwise>gl-cor:entryNumberCounter zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(gl-cor:entryDetail) &gt; 1"/>
         <xsl:otherwise>gl-cor:entryHeader elemanı en az iki gl-cor:entryDetail elemanı içermelidir.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:totalDebit = gl-bus:totalCredit"/>
         <xsl:otherwise>gl-bus:totalDebit elemanının değeri gl-bus:totalCredit elemanının değerine eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:totalDebit = sum(gl-cor:entryDetail[gl-cor:debitCreditCode = 'D' or gl-cor:debitCreditCode = 'debit']/xs:decimal(gl-cor:amount))"/>
         <xsl:otherwise>gl-bus:totalDebit değeri, gl-cor:entryDetail elemanı içerisindeki gl-cor:debitCreditCode değeri 'D' ve ya 'debit' olan gl-cor:amount değelerinin toplamına eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:totalCredit = sum(gl-cor:entryDetail[gl-cor:debitCreditCode = 'C' or gl-cor:debitCreditCode = 'credit']/xs:decimal(gl-cor:amount))"/>
         <xsl:otherwise>gl-bus:totalCredit değeri, gl-cor:entryDetail elemanı içerisindeki gl-cor:debitCreditCode değeri 'C' ve ya 'credit' olan gl-cor:amount değerlerinin toplamına eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(gl-bus:totalDebit) , '^[0-9]+(\.[0-9]{1,2})?$')"/>
         <xsl:otherwise>gl-bus:totalDebit (<xsl:text/>
            <xsl:value-of select="gl-bus:totalDebit"/>
            <xsl:text/> ) virgülden sonra 2 haneden fazla olamaz.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(gl-bus:totalCredit) , '^[0-9]+(\.[0-9]{1,2})?$')"/>
         <xsl:otherwise>gl-bus:totalCredit (<xsl:text/>
            <xsl:value-of select="gl-bus:totalCredit"/>
            <xsl:text/> ) virgülden sonra 2 haneden fazla olamaz.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>
   <!--PATTERN entrydetail-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entryHeader/gl-cor:entryDetail"
                 priority="1000"
                 mode="M27">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:lineNumber"/>
         <xsl:otherwise>gl-cor:lineNumber zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:lineNumberCounter"/>
         <xsl:otherwise>gl-cor:lineNumberCounter zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:lineNumberCounter) or not(parent::node()/gl-cor:entryNumberCounter) or gl-cor:lineNumberCounter = parent::node()/gl-cor:entryNumberCounter"/>
         <xsl:otherwise>gl-cor:lineNumberCounter elemanının değeri bir üst düzeydeki gl-cor:entryNumberCounter elemanının değerine eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:account"/>
         <xsl:otherwise>gl-cor:account zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:account) or not(gl-cor:account/gl-cor:accountMainID) or string-length(gl-cor:account/normalize-space(gl-cor:accountMainID)) = 3 or string-length(gl-cor:account/normalize-space(gl-cor:accountMainID)) = 4"/>
         <xsl:otherwise>gl-cor:account elemanı içerisinde gl-cor:accountMainID zorunlu bir elemandır ve en az 3 karakter olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:account) or gl-cor:account/gl-cor:accountMainDescription"/>
         <xsl:otherwise>gl-cor:account elemanı içerisinde gl-cor:accountMainDescription zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:account/gl-cor:accountSub) or gl-cor:account/gl-cor:accountSub/gl-cor:accountSubID"/>
         <xsl:otherwise>gl-cor:accountSub elemanı içerisinde gl-cor:accountSubID zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:account/gl-cor:accountSub) or gl-cor:account/gl-cor:accountSub/gl-cor:accountSubDescription"/>
         <xsl:otherwise>gl-cor:accountSub elemanı içerisinde gl-cor:accountSubDescription zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="anaHesapId"
                    select="gl-cor:account/normalize-space(gl-cor:accountMainID)"/>
      <xsl:variable name="altHesapId"
                    select="gl-cor:account/normalize-space(gl-cor:accountSub/gl-cor:accountSubID)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($anaHesapId) or not($altHesapId) or starts-with($altHesapId, $anaHesapId)"/>
         <xsl:otherwise>gl-cor:accountSubID(alt hesap numarası) elemanı gl-cor:accountMainID(ana hesap numarası) değeri ile başlamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:amount"/>
         <xsl:otherwise>gl-cor:amount zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:amount) or gl-cor:amount &gt; 0"/>
         <xsl:otherwise>gl-cor:amount elemanı 0'dan büyük bir değer almalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-muc:amountCurrency) or  /edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:documentInfo/gl-muc:defaultCurrency"/>
         <xsl:otherwise>gl-muc:amountCurrency olması durumunda gl-muc:defaultCurrency elemanı da bulunmalıdır <xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-muc:amountOriginalAmount) or gl-muc:amountOriginalExchangeRateDate"/>
         <xsl:otherwise> gl-muc:amountOriginalAmount elemanı olması durumunda gl-muc:amountOriginalExchangeRateDate elemanı da bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-muc:amountOriginalAmount) or gl-muc:amountOriginalCurrency"/>
         <xsl:otherwise>gl-muc:amountOriginalAmount elemanı olması durumunda gl-muc:amountOriginalCurrency elemanı da bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-muc:amountOriginalCurrency) or gl-muc:amountOriginalExchangeRate"/>
         <xsl:otherwise>gl-muc:amountOriginalCurrency elemanı olması durumunda gl-muc:amountOriginalExchangeRate elemanı da bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:debitCreditCode"/>
         <xsl:otherwise>gl-cor:debitCreditCode zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-cor:postingDate"/>
         <xsl:otherwise>gl-cor:postingDate zorunlu bir elemandır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:postingDate) or not(parent::node()/gl-cor:enteredDate) or gl-cor:postingDate = parent::node()/gl-cor:enteredDate"/>
         <xsl:otherwise>gl-cor:postingDate elemanının değeri bir üst düzeydeki gl-cor:enteredDate elemanının değerine eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(normalize-space(gl-cor:documentType) = 'other') or string-length(normalize-space(gl-cor:documentTypeDescription)) &gt; 0"/>
         <xsl:otherwise>gl-cor:documentType eleman değerinin 'other' olması durumunda gl-cor:documentTypeDescription zorunlu bir elemandır ve bu elemanın değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(normalize-space(gl-cor:documentType) = 'other') or (string-length(normalize-space(gl-cor:documentNumber)) &gt; 0 and gl-cor:documentDate)"/>
         <xsl:otherwise>gl-cor:documentType elemanının değeri 'other' olması durumunda gl-cor:documentNumber ve gl-cor:documentDate elemanları da olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(normalize-space(gl-cor:documentType) = 'invoice') or (string-length(normalize-space(gl-cor:documentNumber)) &gt; 0 and gl-cor:documentDate)"/>
         <xsl:otherwise>gl-cor:documentType elemanının değeri 'invoice' (fatura) olması durumunda gl-cor:documentNumber ve gl-cor:documentDate elemanları da olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(normalize-space(gl-cor:documentType) = 'check') or (string-length(normalize-space(gl-cor:documentNumber)) &gt; 0 and gl-cor:documentDate)"/>
         <xsl:otherwise>gl-cor:documentType elemanının değeri 'check' (çek) olması durumunda gl-cor:documentNumber ve gl-cor:documentDate elemanları da olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:documentNumber) or gl-cor:documentType"/>
         <xsl:otherwise>gl-cor:documentNumber elemanı olması durumunda gl-cor:documentType elemanı bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:documentDate) or gl-cor:documentType"/>
         <xsl:otherwise>gl-cor:documentDate elemanı olması durumunda gl-cor:documentType elemanı bulunmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-cor:documentReference) or not(parent::node()/gl-cor:entryNumber) or gl-cor:documentReference = parent::node()/gl-cor:entryNumber"/>
         <xsl:otherwise>gl-cor:documentReference elemanının değeri bir üst düzeydeki gl-cor:entryNumber elemanının değerine eşit olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(gl-bus:paymentMethod) or string-length(normalize-space(gl-bus:paymentMethod)) &gt; 0 "/>
         <xsl:otherwise>gl-bus:paymentMethod elemanı var ise değeri boşluk olmamalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(gl-bus:measurable) &lt; 2"/>
         <xsl:otherwise>En fazla 1 adet gl-bus:measurable elemanı olabilir.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(gl-cor:amount) , '^[0-9]+(\.[0-9]{1,2})?$')"/>
         <xsl:otherwise>gl-cor:amount (<xsl:text/>
            <xsl:value-of select="gl-cor:amount"/>
            <xsl:text/>) virgülden sonra 2 haneden fazla olamaz.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
   </xsl:template>
   <!--PATTERN measurable-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/xbrli:xbrl/gl-cor:accountingEntries/gl-cor:entryHeader/gl-cor:entryDetail/gl-bus:measurable"
                 priority="1000"
                 mode="M28">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableCode"/>
         <xsl:otherwise>gl-bus:measurableCode elemanı zorunludur.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableCodeDescription"/>
         <xsl:otherwise>gl-bus:measurableCodeDescription elemanı zorunludur.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableQuantity"/>
         <xsl:otherwise>gl-bus:measurableQuantity elemanı zorunludur.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableQualifier"/>
         <xsl:otherwise>gl-bus:measurableQualifier elemanı zorunludur.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableUnitOfMeasure"/>
         <xsl:otherwise>gl-bus:measurableUnitOfMeasure elemanı zorunludur.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableCostPerUnit"/>
         <xsl:otherwise>gl-bus:measurableCostPerUnit elemanı zorunludur.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableCode='NT'"/>
         <xsl:otherwise>gl-bus:measurableCode elemanının değeri "NT" olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableCodeDescription='Maddi Olmayan Kalemler'"/>
         <xsl:otherwise>gl-bus:measurableCodeDescription elemanının değeri "Maddi Olmayan Kalemler" olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableQualifier='Fon'"/>
         <xsl:otherwise>gl-bus:measurableQualifier elemanının değeri "Fon" olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="gl-bus:measurableUnitOfMeasure='Adet'"/>
         <xsl:otherwise>gl-bus:measurableUnitOfMeasure elemanının değeri "Adet" olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="parent::node()/gl-cor:amount=gl-bus:measurableCostPerUnit*gl-bus:measurableQuantity"/>
         <xsl:otherwise> gl-bus:measurableCostPerUnit * gl-bus:measurableQuantity = gl-cor:amount olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
   </xsl:template>
   <!--PATTERN binaryObject-->
   <!--RULE -->
   <xsl:template match="/edefter:defter/extensions/extension/defterek:binaryObject"
                 priority="1000"
                 mode="M29">

      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@mimeCode = 'application/pdf'"/>
         <xsl:otherwise>defterek:binaryObject elemanının mimeCode niteliği 'application/pdf' olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="substring(@filename, string-length(@filename)-3)='.pdf'"/>
         <xsl:otherwise>defterek:binaryObject elemanının filename niteliğinin son 4 karakteri '.pdf' olmalıdır.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.))&gt; 0"/>
         <xsl:otherwise> defterek:binaryObject elemanının değeri boşluk olamaz.<xsl:value-of select="string('&#xA;')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>
</xsl:stylesheet>
