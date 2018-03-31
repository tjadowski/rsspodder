<?xml version="1.0"?>
<xsl:transform version="1.0"
    xmlns:a="http://www.w3.org/2005/Atom"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	<xsl:template match="*">
		<xsl:apply-templates select="/a:feed/a:entry/a:link[not(@rel) or @rel='alternate']"/>
	</xsl:template>
	<xsl:template match="a:link[not(@rel) or @rel='alternate']">
        <xsl:value-of select="@href"/><xsl:text>&#10;</xsl:text>
	</xsl:template>
</xsl:transform>
