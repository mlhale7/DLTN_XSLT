<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    version="2.0" xmlns="http://www.loc.gov/mods/v3">
    <xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="coredctomods.xsl"/>
    <xsl:include href="thumbnailsfedoradctomods.xsl"/>
    <xsl:include href="remediationgettygenre.xsl"/>
    <xsl:include href="remediationlcshtopics.xsl"/>
    <xsl:include href="remediationspatial.xsl"/>
    
    <!-- Collection/Set = Institution for Crossroads, so only 1 institution-level transform needed -->
        
    <xsl:template match="text()|@*"/>    
    <xsl:template match="//oai_dc:dc">
        <xsl:if test=".[(every $t in dc:title satisfies $t[not(normalize-space(.) = '')])
                        and (some $i in dc:identifier satisfies $i[starts-with(normalize-space(.), 'http://')])
                        and (some $r in dc:rights satisfies $r[not(normalize-space(.) = '')])]">
            <mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns="http://www.loc.gov/mods/v3" version="3.5"
                  xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
                <xsl:apply-templates select="dc:title"/> <!-- titleInfo/title -->
                <xsl:apply-templates select="dc:creator"/> <!-- name -->
                <xsl:apply-templates select="dc:contributor"/> <!-- name -->
                <xsl:apply-templates select="dc:identifier"/> <!-- identifier -->

                <xsl:if test="dc:date|dc:publisher">
                    <originInfo>
                        <xsl:apply-templates select="dc:date"/> <!-- date (text + key) -->
                        <xsl:apply-templates select="dc:publisher"/> <!-- publisher NOT digital library -->
                    </originInfo>
                </xsl:if>

                <xsl:if test="dc:medium|dc:format|dc:hasversion|dc:provenance">
                    <physicalDescription>
                        <xsl:apply-templates select="dc:medium" mode="form"/> <!-- form -->
                        <xsl:apply-templates select="dc:format"/> <!-- internetMediaType -->
                        <xsl:apply-templates select="dc:hasversion"/> <!-- digitalOrigin -->
                        <xsl:apply-templates select="dc:provenance"
                                             mode="digitalOrigin"/> <!-- digitalOrigin sometimes -->
                    </physicalDescription>
                </xsl:if>

                <xsl:if test="dc:source|dc:identifier">
                    <location>
                        <xsl:apply-templates select="dc:source" mode="physicalLocation"/> <!-- repository -->
                        <xsl:apply-templates select="dc:identifier"
                                             mode="crossroadsURL"/> <!-- object in context URL -->
                        <xsl:apply-templates select="dc:identifier" mode="locationurl"/> <!-- preview -->
                    </location>
                </xsl:if>

                <xsl:apply-templates select="dc:medium"/> <!-- genre -->
                <xsl:apply-templates select="dc:language"/> <!-- language -->
                <xsl:apply-templates select="dc:description"/> <!-- abstract -->
                <xsl:call-template name="rightsRepair"/> <!-- accessCondition -->
                <xsl:apply-templates select="dc:bibliographiccitation"/> <!-- accessCondition -->
                <xsl:apply-templates select="dc:subject"/> <!-- subject/topical -->
                <xsl:apply-templates select="dc:spatial"/> <!-- subject/geographic-->
                <xsl:apply-templates select="dc:temporal"/> <!-- subject/temporal-->
                <xsl:apply-templates select="dc:availability"/> <!-- extension -->
                <xsl:apply-templates select="dc:type"/> <!-- typeOfResource -->
                <xsl:apply-templates select="dc:relation"/> <!-- Related Items -->
                <xsl:apply-templates select="dc:provenance"/> <!-- Related Items mostly -->
                <xsl:apply-templates select="dc:source"/> <!-- Related Items sometimes -->
                <relatedItem type='host' displayLabel="Project">
                    <titleInfo>
                        <title>Crossroads to Freedom Digital Archive</title>
                    </titleInfo>
                    <location>
                        <url>http://www.crossroadstofreedom.org/</url>
                    </location>
                </relatedItem>
                <recordInfo>
                    <recordContentSource>Rhodes College. Crossroads to Freedom</recordContentSource>
                    <recordChangeDate>
                        <xsl:value-of select="current-date()"/>
                    </recordChangeDate>
                    <languageOfCataloging>
                        <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                    </languageOfCataloging>
                    <recordOrigin>Record has been transformed into MODS 3.5 from a qualified Dublin Core record by the
                        Digital Library of Tennessee, a service hub of the Digital Public Library of America, using a
                        stylesheet available at https://github.com/utkdigitalinitiatives/DLTN. Metadata originally
                        created in a locally modified version of qualified Dublin Core using Fedora (data dictionary
                        available: https://wiki.lib.utk.edu/display/DPLA.)
                    </recordOrigin>
                </recordInfo>
            </mods>
        </xsl:if>

    </xsl:template>
    
    <!-- Collection = Institution here, so there is both the collection and institution specific transform. 
        Included templates:
        
        dc:availability
        dc:bibliographiccitation
        dc:contributor
        dc:coverage
        dc:creator
        dc:format
        dc:hasversion
        dc:medium
        dc:medium mode="form"
        dc:provenance
        dc:provenance mode="digitalOrigin"
        dc:publisher
        dc:relation
        dc:source
        dc:source mode="physicalLocation"
        dc:spatial
        dc:subject
        dc:temporal
        dc:type
        -->
    
    <xsl:template match="dc:availability">
        <extension xmlns:dcterms="http://purl.org/dc/terms/">
            <dcterms:available encoding="edtf"><xsl:value-of select="."/></dcterms:available>
        </extension>
    </xsl:template>
    
    <xsl:template match="dc:bibliographiccitation">
        <xsl:if test="lower-case(normalize-space(.)) != 'n/a'">
            <note><xsl:value-of select="."/></note>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:contributor">
        <xsl:if test="normalize-space(.)!='' and lower-case(normalize-space(.)) != 'n/a'">
            <xsl:choose>
                <xsl:when test="contains(., 'interviewer')">
                    <name>
                        <namePart><xsl:value-of select="replace(., ', interviewer', '')"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ivr"><xsl:text>Interviewer</xsl:text></roleTerm>
                        </role> 
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:when>
                <xsl:when test="contains(., 'digitization')">
                    <name>
                        <namePart><xsl:value-of select="replace(., ', digitization', '')"/></namePart>
                        <role>
                            <roleTerm type="text"><xsl:text>Digitizer</xsl:text></roleTerm>
                        </role> 
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:when>
                <xsl:when test="contains(., '(processing)')">
                    <name>
                        <namePart>
                            <xsl:value-of select="replace(., ' (processing)', '')"/>
                        </namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/prc"><xsl:text>Process contact</xsl:text></roleTerm>
                        </role> 
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:when>
                <xsl:when test="contains(., 'processor')">
                    <name>
                        <namePart><xsl:value-of select="replace(., ', processor', '')"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/prc"><xsl:text>Process contact</xsl:text></roleTerm>
                        </role> 
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:when>
                <xsl:when test="contains(., ', camera')">
                    <name>
                        <namePart><xsl:value-of select="replace(., ', camera', '')"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/vdg"><xsl:text>Videographer</xsl:text></roleTerm>
                        </role> 
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:when>
                <xsl:when test="contains(., '(camera)')">
                    <name>
                        <namePart><xsl:value-of select="replace(., ' (camera)', '')"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/vdg"><xsl:text>Videographer</xsl:text></roleTerm>
                        </role> 
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:when>
                <xsl:otherwise>
                    <name>
                        <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb"><xsl:text>Contributor</xsl:text></roleTerm>
                        </role> 
                    </name>
                </xsl:otherwise>
            </xsl:choose>          
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:coverage">
        <xsl:if test="normalize-space(.)!=''">
            <xsl:choose>
                <!-- check to see if there are any numbers in this coverage value -->
                <xsl:when test='matches(.,"\d+")'>
                    <xsl:choose>
                        <!-- if numbers follow a coordinate pattern, it's probably geo data - which should go in cartographics/coordinates child element -->
                        <xsl:when test='matches(.,"\d+\.\d+")'>
                            <subject>
                                <cartographics>
                                    <coordinates><xsl:value-of select="normalize-space(.)"/></coordinates>
                                </cartographics>
                            </subject>
                        </xsl:when>
                        <!-- if there's no coordinate pattern, it's probably temporal data; put it in temporal -->
                        <xsl:otherwise>
                            <subject>
                                <temporal><xsl:value-of select="normalize-space(.)"/></temporal>
                            </subject>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- if there are no numbers, it's probably geo data as text --> 
                <xsl:otherwise>
                    <subject>
                        <geographic><xsl:value-of select="normalize-space(.)"/></geographic>
                    </subject>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template> 
    
    <xsl:template match="dc:creator">
        <xsl:variable name="creatorvalue" select="normalize-space(.)"/>
        <xsl:if test="normalize-space(.)!='' and lower-case(normalize-space(.)) != 'n/a' and not(contains(., 'nknown'))">
            <xsl:choose>
                <xsl:when test="contains(., 'Crossroad')">
                    <!-- skip -->
                </xsl:when>
                <xsl:otherwise>
                    <name>
                        <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/cre"><xsl:text>Creator</xsl:text></roleTerm>
                        </role>
                    </name> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>          
    </xsl:template>
    
    <xsl:template match="dc:format"> <!-- should go into PhysicalDescription wrapper -->
        <xsl:if test="normalize-space(.)!=''">
            <xsl:choose>
                <xsl:when test="contains(., 'jpg') or contains(., 'jpeg')">
                    <internetMediaType>image/jpeg</internetMediaType>
                </xsl:when>
                <xsl:when test="contains(., 'flash audio')">
                    <internetMediaType>audio/mp4</internetMediaType>
                    <note>flash audio</note>
                </xsl:when>
                <xsl:when test="contains(., 'flash video')">
                    <internetMediaType>video/mp4</internetMediaType>
                    <note>flash video</note>
                </xsl:when>
                <xsl:when test="contains(., 'pdf')">
                    <internetMediaType>application/pdf</internetMediaType>
                    <note>PDF</note>
                </xsl:when>
                <xsl:when test="contains(., 'word')">
                    <internetMediaType>application/msword</internetMediaType>
                    <note>Microsoft Word Document</note>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:hasversion"> <!-- should go into PhysicalDescription wrapper -->
        <xsl:if test="normalize-space(lower-case(.)) != 'n/a' and normalize-space(lower-case(.)) != ''">
            <xsl:choose>
                <xsl:when test="contains(normalize-space(lower-case(.)), 'born digital')">
                    <digitalOrigin>born digital</digitalOrigin>
                </xsl:when>
                <xsl:when test="contains(normalize-space(lower-case(.)), 'crossroads video') or contains(normalize-space(lower-case(.)), 'crossroadsvideo')">
                    <digitalOrigin>reformatted digital</digitalOrigin>
                    <note>Crossroads video</note>
                </xsl:when>
                <xsl:when test="contains(normalize-space(lower-case(.)), 'crossroadstext') or contains(normalize-space(lower-case(.)), 'crossroads text')">
                    <digitalOrigin>reformatted digital</digitalOrigin>
                    <note>Crossroads text</note>
                </xsl:when>
                <xsl:otherwise>
                    <note>
                        <xsl:value-of select="normalize-space(.)"/>
                    </note>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:medium">
        <xsl:if test="normalize-space(.)!=''">
            <xsl:call-template name="AATgenre">
                <xsl:with-param name="term"><xsl:value-of select="lower-case(normalize-space(.))"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:medium" mode="form">
        <xsl:if test="normalize-space(.)!='' and not(contains(normalize-space(lower-case(.)), 'tennessee'))">
            <form><xsl:value-of select="normalize-space(lower-case(.))"/></form>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:provenance">
        <xsl:if test="not(contains(lower-case(.), 'n/a') or contains(lower-case(.), 'born digital'))">
            <relatedItem type="host" displayLabel="Collection">
                <titleInfo>
                    <title><xsl:value-of select="."/></title>
                </titleInfo>
            </relatedItem>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:provenance" mode="digitalOrigin">
        <xsl:if test="not(contains(lower-case(.), 'n/a')) and contains(lower-case(.), 'born digital')">
            <digitalOrigin><xsl:value-of select="normalize-space(lower-case(.))"/></digitalOrigin>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:publisher"> <!-- will block publisher being the institution/collection -->
        <xsl:if test="normalize-space(.)!='' and not(contains(lower-case(normalize-space(dc:publisher)),'crossroads to freedom'))">
            <publisher><xsl:value-of select="normalize-space(.)"/></publisher>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:relation">
        <xsl:if test="normalize-space(.)!='' and normalize-space(lower-case(.))!='n/a'">
            <xsl:choose>
                <xsl:when test="contains(.,'http') or starts-with(., 'rdf:')"> 
                    <relatedItem>
                        <xsl:if test="contains(., 'http')">
                            <location>
                                <url><xsl:value-of select="normalize-space(.)"/></url>
                            </location>
                        </xsl:if>
                        <xsl:if test="starts-with(., 'rdf:')">
                            <identifier><xsl:value-of select="normalize-space(.)"/></identifier>
                        </xsl:if>
                    </relatedItem>
                </xsl:when>
                <xsl:when test="contains(normalize-space(lower-case(.)), 'Tennessee')">
                    <subject>
                        <geographic><xsl:value-of select="normalize-space(.)"/></geographic>
                    </subject>
                </xsl:when>
                <xsl:when test="matches(normalize-space(.), '^\d{4}')">
                    <subject>
                        <temporal><xsl:value-of select="normalize-space(.)"/></temporal>
                    </subject>
                </xsl:when>
                <xsl:otherwise>
                    <relatedItem>
                        <titleInfo>
                            <title><xsl:value-of select="normalize-space(.)"/></title>
                        </titleInfo>
                    </relatedItem>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="rightsRepair"> <!-- some elements missing rights statement, which is required. Existing mapped, those without, given generic.-->
        <xsl:choose>
            <xsl:when test="dc:rights">
                <xsl:apply-templates select="dc:rights"/>
            </xsl:when>
            <xsl:otherwise>
                <accessCondition type='local rights statement'>Crossroads to Freedom Digital Archive is licensed under the Creative Commons Attribution License. Use of the site's content is subject to the conditions and terms of use on our Legal Notices page.</accessCondition>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- The top spatial facets that cover about 99% of the total records are accounted for in the template below. This process was semi automated using OpenRefine in the context of this particular collection -->
    <xsl:template match="dc:spatial">
        <xsl:if test="not(matches(., '^\d+\w+$')) and not(contains(normalize-space(lower-case(.)), 'n/a')) and not(contains(normalize-space(lower-case(.)), 'unknown')) and not(contains(normalize-space(lower-case(.)), 'various'))"> <!-- data contains some random numbers/dates -->
            <xsl:for-each select="tokenize(., ' and ')">
                <xsl:call-template name="SpatialTopic">
                    <xsl:with-param name="term"><xsl:value-of select="normalize-space(lower-case(.))"/></xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:source">
        <xsl:choose>
            <xsl:when test="contains(lower-case(.), 'collection') or contains(lower-case(.), 'corp')">
                <relatedItem type="host" displayLabel="Collection">
                    <titleInfo>
                        <title><xsl:value-of select="normalize-space(.)"/></title>
                    </titleInfo>
                </relatedItem>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dc:source" mode="physicalLocation">
        <xsl:if test="contains(lower-case(.), 'archive') or contains(lower-case(.), 'library') or contains(lower-case(.), 'association') or starts-with(lower-case(normalize-space(.)), 'http://')">
            <physicalLocation><xsl:value-of select="normalize-space(.)"/></physicalLocation>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:subject">
        <xsl:if test="normalize-space(.)!=''">
            <xsl:call-template name="LCSHtopic">
                <xsl:with-param name="term"><xsl:value-of select="lower-case(normalize-space(replace(replace(., ' - ', '--'), ' -- ', '--')))"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:temporal">
        <xsl:choose>
            <xsl:when test="matches(., '^\d{4}$') or matches(., '^\d{4}-\d{2}$') or matches(., '^\d{4}-\d{2}-\d{2}$')">
                <subject>
                    <temporal encoding="edtf"><xsl:value-of select="."/></temporal>
                </subject>
            </xsl:when>
            <xsl:when test="contains(lower-case(.), 'unknown') or contains(lower-case(.), 'n/a')">
            </xsl:when>
            <xsl:when test="not(contains(., '\d+'))">
                <subject>
                    <geographic><xsl:value-of select="."/></geographic>
                </subject>
            </xsl:when>
            <xsl:otherwise>
                <subject>
                    <temporal><xsl:value-of select="."/></temporal>
                </subject>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dc:type">
        <xsl:choose>
            <xsl:when
                test="string(text()) = 'MovingImage' or string(text()) = 'movingimage' or string(text()) = 'Moving Image' or string(text()) = 'moving image' or string(text()) = 'movingImage'">
                <typeOfResource>moving image</typeOfResource>
            </xsl:when>
            <xsl:when test="string(text()) = 'PhysicalObject' or string(text()) = 'physicalobject' or string(text()) = 'Physical Object' or string(text()) = 'physical object' or string(text()) = 'physicalObject'">
                <typeOfResource>three dimensional object</typeOfResource>
            </xsl:when>
            <xsl:when test="string(text()) = 'Service' or string(text()) = 'service'">
                <typeOfResource>software, multimedia</typeOfResource>
            </xsl:when>
            <xsl:when test="string(text()) = 'Software' or string(text()) = 'software'">
                <typeOfResource>software, multimedia</typeOfResource>
            </xsl:when>
            <xsl:when test="string(text()) = 'Sound' or string(text()) = 'sound'">
                <typeOfResource>sound recording</typeOfResource>
            </xsl:when>
            <xsl:when test="string(text()) = 'StillImage' or string(text()) = 'stillimage' or string(text()) = 'Still Image' or string(text()) = 'still image' or string(text()) = 'stillImage'">
                <typeOfResource>still image</typeOfResource>
            </xsl:when>
            <xsl:when test="string(text()) = 'Text' or string(text()) = 'text'">
                <typeOfResource>text</typeOfResource>
            </xsl:when>
        </xsl:choose>  
    </xsl:template>
    
</xsl:stylesheet>
