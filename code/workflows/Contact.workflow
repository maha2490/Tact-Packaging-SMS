<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateMogliNumber</fullName>
        <description>Update Mogli Number based on value in Mobile field (remove all non-numerical values)</description>
        <field>Mogli_Number__c</field>
        <formula>SUBSTITUTE(
SUBSTITUTE(
SUBSTITUTE(
SUBSTITUTE(MobilePhone, &quot;(&quot;, &quot;&quot;), &quot;)&quot;, &quot;&quot;), &quot; &quot;, &quot;&quot;), &quot;-&quot;, &quot;&quot;)</formula>
        <name>Update Mogli Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mogli_Number_with_WITH_PLUS</fullName>
        <description>Update Mogli Number based on value in Mobile field (remove all non-numerical values) WITH PLUS added to front of Mogli Number</description>
        <field>Mogli_Number__c</field>
        <formula>&quot;+1&quot;&amp; SUBSTITUTE(
       SUBSTITUTE(
        SUBSTITUTE(
         SUBSTITUTE(
          SUBSTITUTE(MobilePhone , &quot;(&quot;, &quot;&quot;),&quot;)&quot;,&quot;&quot;),&quot;-&quot;,&quot;&quot;),&quot; &quot;,&quot;&quot;),&quot;+&quot;,&quot;&quot;)</formula>
        <name>Update Mogli Number with WITH PLUS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WITH PLUS - onCreateEditWhenMobileNotNull</fullName>
        <actions>
            <name>Update_Mogli_Number_with_WITH_PLUS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.MobilePhone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Mogli Number based on value in Mobile field (remove all non-numerical values) WITH PLUS added to front of Mogli Number</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>onCreateEditWhenMobileNotNull</fullName>
        <actions>
            <name>UpdateMogliNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.MobilePhone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Mogli Number based on value in Mobile field (and remove all non-numerical values)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
