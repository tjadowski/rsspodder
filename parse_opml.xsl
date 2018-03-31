<?xml version="1.0"?>
<stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/XSL/Transform">
	<output method="text"/>
	<template match="/">
          <apply-templates select="/opml/body/outline/outline"/>
	</template>
	<template match="outline">
        <value-of select="@xmlUrl"/><text>&#10;</text>
	</template>
</stylesheet>
