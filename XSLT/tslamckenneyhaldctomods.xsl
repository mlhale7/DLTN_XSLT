<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    version="2.0" xmlns="http://www.loc.gov/mods/v3">
    <xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="tsladctomods.xsl"/>
        
    <xsl:template match="text()|@*"/>    
    <xsl:template match="//oai_dc:dc">
        <!-- if statement blocks output of TSLA records that are at item/part-level-->
        <xsl:if test="not(matches(dc:title/text(), '_\d+$'))">
        <mods xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://www.loc.gov/mods/v3" version="3.5" 
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates select="dc:title"/> <!-- titleInfo/title and part/detail|date parsed out -->
            <xsl:apply-templates select="dc:identifier"/> <!-- identifier -->
            <xsl:apply-templates select="dc:creator"/> <!-- creator -->
            
            <xsl:if test="dc:date">
                <originInfo> 
                    <xsl:apply-templates select="dc:date"/> <!-- date (text + key) -->
                    <xsl:apply-templates select="dc:publisher"/> <!-- publisher -->
                </originInfo>
            </xsl:if>
            
            <xsl:if test="dc:format">
                <physicalDescription>
                    <xsl:apply-templates select="dc:format"/> <!-- internetMediaType -->
                </physicalDescription>
            </xsl:if>
            
            <xsl:if test="dc:identifier">
                <location>
                    <xsl:apply-templates select="dc:identifier" mode="URL"/> <!-- object in context URL -->
                    <xsl:apply-templates select="dc:identifier" mode="locationurl"/> <!-- thumbnail url -->
                    <xsl:apply-templates select="dc:source" mode="repository"/>
                </location>
            </xsl:if>
            
            <xsl:apply-templates select="dc:subject"/> <!-- subject -->
            <xsl:apply-templates select="dc:description"/> <!-- abstract -->
            <xsl:call-template name="rightsRepair"/> <!-- accessCondition -->
            <xsl:apply-templates select="dc:type"/> <!-- item types -->
            <xsl:if test="dc:relation">
                <relatedItem>
                    <xsl:apply-templates select="dc:relation"/>
                </relatedItem>
            </xsl:if>
            <xsl:apply-templates select="dc:source"/> <!-- collection -->
            <relatedItem type='host' displayLabel="Project">
                <titleInfo>
                    <title>McKenney-Hall 19th Century Native-American Prints</title>
                </titleInfo>
                <abstract>This three-volume set of Native-American portraits, entitled the History of The Indian Tribes of North America, with Biographical Sketches and Anecdotes of the Principal Chiefs, was assembled by Thomas L. McKenney and James Hall between 1836 and 1844. The images document a number of tribes on the cusp of their decline and forcible removal by the United States government.  McKenney, the head of the Bureau of Indian Affairs from 1824 to 1830, commissioned their portraits when Native American chiefs and other representatives visited Washington to negotiate treaties; many of them are wearing peace medals issued by the United States government. Charles Bird King, with the assistance of George Cooke, painted many of the images, as well as James Otto Lewis. The paintings were later lost in a fire, but before their destruction they were copied by Henry Inman and then made into lithographs by the Philadelphia printer Edward C. Biddle. The images selected for this TEVA exhibit represent tribes that were associated with Tennessee and the surrounding area, including the Cherokee, Creeks, and Choctaw Indians. The accompanying text was written by Hall, and, while intriguing, should be viewed through a historiographic lens...</abstract>
                <location>
                    <url>http://cdm15138.contentdm.oclc.org/cdm/landingpage/collection/mckenneyHal</url>
                </location>
            </relatedItem>
            <xsl:call-template name="recordSource"/>
        </mods>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:coverage">
        <xsl:if test="normalize-space(.)!='' and normalize-space(lower-case(.))!='unknown'">
            <xsl:choose>
                <xsl:when test="matches(., '\d+')">
                    <subject>
                        <temporal><xsl:value-of select="normalize-space(.)"/></temporal>
                    </subject>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="SpatialTopic">
                        <xsl:with-param name="term"><xsl:value-of select="."/></xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:format"> <!-- should go into PhysicalDescription wrapper -->
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <xsl:if test="normalize-space(.)!=''">
                <xsl:choose>
                    <xsl:when test="matches(normalize-space(lower-case(.)), 'image/jpeg')">
                        <internetMediaType>image/jpeg</internetMediaType>
                    </xsl:when>
                    <xsl:when test="matches(normalize-space(lower-case(.)), 'image/jp2')">
                        <internetMediaType>image/jp2</internetMediaType>
                    </xsl:when>
                    <xsl:when test="matches(normalize-space(lower-case(.)), 'tiff')">
                        <internetMediaType>image/tiff</internetMediaType>
                    </xsl:when>
                    <xsl:when test="matches(normalize-space(.), '\d+')">
                        <extent><xsl:value-of select="normalize-space(.)"/></extent>
                    </xsl:when>
                    <xsl:otherwise>
                        <note><xsl:value-of select="normalize-space(.)"/></note>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="dc:relation"> <!-- off mix of identifiers - some are identifiers for collections? can't verify -->
        <xsl:if test="normalize-space(.)!=''">
            <identifier><xsl:value-of select="normalize-space(.)"/></identifier>
        </xsl:if>
    </xsl:template>
 
    <xsl:template match="dc:source">
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <xsl:if test="normalize-space(.)!=''">
                <xsl:choose>
                    <xsl:when test="contains(., 'State Library') or contains(., 'Society')">
                        <!-- becomes physicalLocation - repository -->
                    </xsl:when>
                    <xsl:when test="starts-with(., 'History of')">
                        <abstract><xsl:value-of select="normalize-space(.)"/></abstract>
                    </xsl:when>
                    <xsl:otherwise>
                        <relatedItem type='host' displayLabel="Collection">
                            <titleInfo>
                                <title><xsl:value-of select="normalize-space(.)"/></title>
                            </titleInfo>
                        </relatedItem>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="dc:source" mode="repository">
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <xsl:if test="normalize-space(.)!='' and (contains(., 'Society') or contains(., 'State Library'))">
                <physicalLocation><xsl:value-of select="normalize-space(.)"/></physicalLocation>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
