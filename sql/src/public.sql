BEGIN;

/*
DROP VIEW view_activeworkresultinstance;
DROP VIEW view_activeworkinstance;
ALTER TABLE workresultinstance DROP CONSTRAINT workresultinstance_workresultinstancevaluelanguagemasterid_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplatenameid_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplatedescriptionid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultlanguagemasterid_fkey;
ALTER TABLE systag DROP CONSTRAINT systag_systagnameid_fkey;
ALTER TABLE systag DROP CONSTRAINT systag_systagabbreviationid_fkey;
ALTER TABLE languagetranslations DROP CONSTRAINT languagetranslations_languagetranslationmasterid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptionlanguagemasterid_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationnameid_fkey;
ALTER TABLE resource DROP CONSTRAINT resource_resourcenameid_fkey;
ALTER TABLE customer DROP CONSTRAINT customer_customernamelanguagemasterid_fkey;
ALTER TABLE custag DROP CONSTRAINT custag_custagnameid_fkey;
ALTER TABLE custag DROP CONSTRAINT custag_custagabbreviationid_fkey;
ALTER TABLE "_customerToregistereddevice" DROP CONSTRAINT "_customerToregistereddevice_B_fkey";
ALTER TABLE apikey DROP CONSTRAINT "apikey_registereddeviceRegistereddeviceid_fkey";
DROP VIEW view_internalcalcformulacheck;
DROP VIEW view_workresultinstance;
DROP VIEW view_activeworkresult;
DROP VIEW view_activeworkresource;
DROP VIEW view_workinstance;
DROP VIEW view_activeworkfrequency;
DROP VIEW view_activeresource;
DROP FUNCTION api.delete_reason_code(uuid,uuid,text,text);
DROP FUNCTION api.delete_location(uuid,uuid);
ALTER TABLE workpictureinstance DROP CONSTRAINT workpictureinstance_workpictureinstanceworkresultinstancei_fkey;
ALTER TABLE workresultinstance DROP CONSTRAINT workresultinstance_workresultinstanceworkresultid_fkey;
ALTER TABLE workresultinstance DROP CONSTRAINT workresultinstance_workresultinstanceworkinstanceid_fkey;
ALTER TABLE workresultinstance DROP CONSTRAINT workresultinstance_workresultinstancestatusid_fkey;
ALTER TABLE workresultinstance DROP CONSTRAINT workresultinstance_workresultinstancemodifiedby_fkey;
ALTER TABLE workresultinstance DROP CONSTRAINT workresultinstance_workresultinstancecustomerid_fkey;
ALTER TABLE workpictureinstance DROP CONSTRAINT workpictureinstance_workpictureinstanceworkinstanceid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstanceworktemplateid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancetypeid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancetrustreasoncodeid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancestatusid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancesiteid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstanceproccessingstatusid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancepreviousid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstanceoriginatorworkinstanceid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancenameid_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancemodifiedby_fkey;
ALTER TABLE workinstance DROP CONSTRAINT workinstance_workinstancecustomerid_fkey;
ALTER TABLE languagetranslations DROP CONSTRAINT languagetranslations_languagetranslationtypeid_fkey;
ALTER TABLE languagetranslations DROP CONSTRAINT languagetranslations_languagetranslationmodifiedby_fkey;
ALTER TABLE entity.entitytemplate DROP CONSTRAINT entitytemplatenameuuid_languagmasteruuid_fk;
ALTER TABLE entity.entityfield DROP CONSTRAINT entityfield_entityfieldlanguagemasteruuid_fkey;
ALTER TABLE languagemaster DROP CONSTRAINT languagemaster_languagemastersourcelanguagetypeid_fkey;
ALTER TABLE languagetranslations DROP CONSTRAINT languagetranslations_languagetranslationcustomersiteid_fkey;
ALTER TABLE languagemaster DROP CONSTRAINT languagemaster_languagemastermodifiedby_fkey;
ALTER TABLE languagetranslations DROP CONSTRAINT languagetranslations_languagetranslationcustomerid_fkey;
ALTER TABLE languagemaster DROP CONSTRAINT languagemaster_languagemastercustomersiteid_fkey;
ALTER TABLE languagemaster DROP CONSTRAINT languagemaster_languagemastercustomerid_fkey;
ALTER TABLE entity.entityfieldinstance DROP CONSTRAINT efi_entityfieldinstancevaluelanguagemasteruuid_fk;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateviaworkre_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateviastatus_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatetypeid_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatesiteid_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateprevioust_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatenexttempl_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatemodifiedb_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatecustomeri_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT constraintid_fkey;
ALTER TABLE workweekexception DROP CONSTRAINT locationid_fkey;
ALTER TABLE workweek DROP CONSTRAINT locationid_fkey;
ALTER TABLE worktemplatedurationcalculation DROP CONSTRAINT siteid_fkey;
ALTER TABLE workinstanceexception DROP CONSTRAINT workinstanceexception_workinstanceexceptionsiteid_fkey;
ALTER TABLE workinstanceexception DROP CONSTRAINT workinstanceexception_workinstanceexceptionlocationid_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT siteid_fkey;
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedsiteid_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplatesiteid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultsiteid_fkey;
ALTER TABLE xtag DROP CONSTRAINT xtag_xsystagid_fkey;
ALTER TABLE xtag DROP CONSTRAINT xtag_xsysparenttagid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstancesiteid_fkey;
ALTER TABLE xlabel DROP CONSTRAINT labletypeid_fkey;
ALTER TABLE workweekexception DROP CONSTRAINT timezoneid_fkey;
ALTER TABLE workweek DROP CONSTRAINT timezoneid_fkey;
ALTER TABLE worktemplatedurationcalculation DROP CONSTRAINT worktype_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationmodifiedby_fkey;
ALTER TABLE worktemplatedurationcalculation DROP CONSTRAINT calculationtype_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstanceuserroleid_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationcustomerid_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT worktype_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT calcualtiontypeid_fkey;
ALTER TABLE worktemplatedurationcalculation DROP CONSTRAINT worktemplatedurationcalculation_worktemplatedurationcalcul_fkey;
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedcalculationid_fkey;
ALTER TABLE workresource DROP CONSTRAINT workresource_workresourceresourcetypeid_fkey;
ALTER TABLE resource DROP CONSTRAINT resource_resourcesiteid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT customerid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptionmimetypeid_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT siteid_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT locationid_fkey;
ALTER TABLE workinstanceexception DROP CONSTRAINT workinstanceexception_workinstanceexceptionmodifiedby_fkey;
ALTER TABLE customer DROP CONSTRAINT customer_customerlanguagetypeid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptionlanguagetypeid_fkey;
ALTER TABLE xtag DROP CONSTRAINT xtag_xtagcustomerid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultmodifiedby_fkey;
ALTER TABLE "user" DROP CONSTRAINT languageid_fkey;
ALTER TABLE xlabel DROP CONSTRAINT customerid_fkey;
ALTER TABLE workfrequencyhistory DROP CONSTRAINT workfrequencyhistory_workfrequencyhistorymodifiedby_fkey;
ALTER TABLE workweekexception DROP CONSTRAINT customerid_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationsiteid_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT workertemplatedurationcalculation_workertemplatedurationca_fkey;
ALTER TABLE workweek DROP CONSTRAINT customerid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresulttypeid_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT workerinstanceid_fkey;
ALTER TABLE worktemplatedurationcalculation DROP CONSTRAINT customerid_fkey;
ALTER TABLE worktemplatetype DROP CONSTRAINT worktemplatetype_worktemplatetypemodifiedby_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationparentid_fkey;
ALTER TABLE workicon DROP CONSTRAINT workicon_workiconcustomerid_fkey;
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedmodifiedby_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT customerid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultentitytypeid_fkey;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstraintmodifiedby_fkey;
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedcustomerid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptioncustomerid_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationcornerstoneid_fkey;
ALTER TABLE "user" DROP CONSTRAINT customerid_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT customerid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstancelanguageid_fkey;
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedworkresultid_fkey;
ALTER TABLE invitationcode DROP CONSTRAINT invitationcode_invitationcodecustomerid_fkey;
ALTER TABLE customerbillingrecord DROP CONSTRAINT customerbillingrecord_customerbillingrecordcustomerid_fkey;
ALTER TABLE location DROP CONSTRAINT location_locationcategoryid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultworktemplateid_fkey;
ALTER TABLE address DROP CONSTRAINT customerid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstanceexternalsystemid_fkey;
ALTER TABLE systag DROP CONSTRAINT systag_systagmodifiedby_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultcustomerid_fkey;
ALTER TABLE registereddevice DROP CONSTRAINT registereddevice_registereddeviceuserroleid_fkey;
ALTER TABLE workresource DROP CONSTRAINT workresource_workresourcemodifiedby_fkey;
ALTER TABLE "_customerToregistereddevice" DROP CONSTRAINT "_customerToregistereddevice_A_fkey";
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedsecondworkresulti_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT worktype_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplatemodifiedby_fkey;
ALTER TABLE customerrequestedlanguage DROP CONSTRAINT customerid_fkey;
ALTER TABLE xlabel DROP CONSTRAINT labelnameid_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT calculationtype_fkey;
ALTER TABLE workresource DROP CONSTRAINT workresource_workresourcecustomerid_fkey;
ALTER TABLE workfrequency DROP CONSTRAINT workfrequency_workfrequencymodifiedby_fkey;
ALTER TABLE workresultcalculated DROP CONSTRAINT workresultcalculated_workresultcalculatedfirstworkresultid_fkey;
ALTER TABLE invitationcode DROP CONSTRAINT invitationcode_invitationcodetransporttypeid_fkey;
ALTER TABLE worktemplatedurationcalculation DROP CONSTRAINT templateid_fkey;
ALTER TABLE custag DROP CONSTRAINT custag_custagcustomerid_fkey;
ALTER TABLE invitationcode DROP CONSTRAINT invitationcode_invitationcodeinvitationtypeid_fkey;
ALTER TABLE workertemplatedurationcalculation DROP CONSTRAINT worktemplateid_fkey;
ALTER TABLE workfrequency DROP CONSTRAINT workfrequency_workfrequencycustomerid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstanceworkerid_fkey;
ALTER TABLE workicon DROP CONSTRAINT workicon_workiconworktemplateid_fkey;
ALTER TABLE worktemplatetype DROP CONSTRAINT worktemplatetype_worktemplatetypecustomerid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstancemodifiedby_fkey;
ALTER TABLE apikey DROP CONSTRAINT apikey_apikeycustomerid_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultwidgetid_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT locationtemplatedurationcalculation_locationtemplatedurati_fkey;
ALTER TABLE "user" DROP CONSTRAINT addressid_fkey;
ALTER TABLE workinstanceexception DROP CONSTRAINT workinstanceexception_workinstanceexceptioncustomerid_fkey;
ALTER TABLE worker DROP CONSTRAINT worker_workermodifiedby_fkey;
ALTER TABLE workresult DROP CONSTRAINT workresult_workresultformatid_fkey;
ALTER TABLE address DROP CONSTRAINT address_addresstimezoneid_fkey;
ALTER TABLE locationtemplatedurationcalculation DROP CONSTRAINT templateid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptionworkresultid_fkey;
ALTER TABLE customer DROP CONSTRAINT customer_customermodifiedby_fkey;
ALTER TABLE address DROP CONSTRAINT address_addressstateid_fkey;
ALTER TABLE resource DROP CONSTRAINT resource_resourcemodifiedby_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplatecustomerid_fkey;
ALTER TABLE address DROP CONSTRAINT address_addresscountryid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptionmodifiedby_fkey;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstraintcustomerid_fkey;
ALTER TABLE customerrequestedlanguage DROP CONSTRAINT systag_fkey;
ALTER TABLE resource DROP CONSTRAINT resource_resourcecustomerid_fkey;
ALTER TABLE worker DROP CONSTRAINT worker_workeraddressid_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplateexpecteddurationtypeid_fkey;
ALTER TABLE custag DROP CONSTRAINT custag_custagmodifiedby_fkey;
ALTER TABLE workpictureinstance DROP CONSTRAINT workpictureinstance_workpictureinstancecustomerid_fkey;
ALTER TABLE workinstanceexception DROP CONSTRAINT workinstanceexception_workinstanceexceptionworktemplateid_fkey;
ALTER TABLE worker DROP CONSTRAINT worker_workerlanguageid_fkey;
ALTER TABLE workfrequencyhistory DROP CONSTRAINT workfrequencyhistory_workfrequencyhistoryworkfrequencyid_fkey;
ALTER TABLE registereddevice DROP CONSTRAINT registereddevice_registereddevicemodifiedby_fkey;
ALTER TABLE workresource DROP CONSTRAINT workresource_workresourceresourcecustomertypeid_fkey;
ALTER TABLE workdescription DROP CONSTRAINT workdescription_workdescriptionworktemplateid_fkey;
ALTER TABLE customerrequestedlanguage DROP CONSTRAINT customerrequestedlanguage_customerrequestedlanguagemodifie_fkey;
ALTER TABLE resource DROP CONSTRAINT resource_resourcetypeid_fkey;
ALTER TABLE workresource DROP CONSTRAINT workresource_workresourceworktemplateid_fkey;
ALTER TABLE worker DROP CONSTRAINT worker_workeridentitysystemid_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplateworkfrequencyid_fkey;
ALTER TABLE apikey DROP CONSTRAINT apikey_apikeymodifiedby_fkey;
ALTER TABLE resource DROP CONSTRAINT resource_resourcecustomertypeid_fkey;
ALTER TABLE workpictureinstance DROP CONSTRAINT workpictureinstance_workpictureinstancemimetypeid_fkey;
ALTER TABLE worktemplate DROP CONSTRAINT worktemplate_worktemplatelocationtypeid_fkey;
ALTER TABLE workpictureinstance DROP CONSTRAINT workpictureinstance_workpictureinstancemodifiedby_fkey;
ALTER TABLE workfrequency DROP CONSTRAINT workfrequency_workfrequencytypeid_fkey;
ALTER TABLE systag DROP CONSTRAINT systag_systagparentid_fkey;
ALTER TABLE registereddevice ALTER registereddeviceid DROP DEFAULT;
DROP VIEW view_workinstance_full_v2;
DROP VIEW view_activeworktemplate;
DROP VIEW view_workresult;
DROP VIEW view_workresource;
DROP VIEW view_workinstance_full;
DROP VIEW view_workfrequency;
DROP VIEW view_activeworkerinstance;
DROP VIEW view_activesystag;
DROP VIEW view_resource;
DROP VIEW view_activelocation;
DROP VIEW view_activecustag;
DROP FUNCTION api.delete_customer_requested_language(uuid,text);
ALTER TABLE entity.entityfieldinstance DROP CONSTRAINT efi_entityfieldinstancemodifiedbyuuid_fk;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateprevlocat_fkey;
ALTER TABLE worktemplatenexttemplate DROP CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatenextlocat_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstanceuserroleuuid_fkey;
ALTER TABLE entity.entityinstance DROP CONSTRAINT entityinstance_entityinstancemodifiedbyuuid_fk;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstancecustomeruuid_fkey;
ALTER TABLE customer DROP CONSTRAINT customer_customertypeuuid_fkey;
ALTER TABLE customer DROP CONSTRAINT customer_customerlanguagetypeuuid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstancelanguageuuid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstanceexternalsystemuuid_fkey;
ALTER TABLE customerconfig DROP CONSTRAINT customerconfig_customerconfigsiteuuid_fkey;
ALTER TABLE workerinstance DROP CONSTRAINT workerinstance_workerinstanceworkeruuid_fkey;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstraintresultid_fkey;
ALTER TABLE customerconfig DROP CONSTRAINT customerconfig_customerconfigvaluetypeuuid_fkey;
ALTER TABLE customerconfig DROP CONSTRAINT customerconfig_customerconfigtypeuuid_fkey;
ALTER TABLE customerbillingrecord DROP CONSTRAINT customerbillingrecord_customerbillingrecordstatusuuid_fkey;
ALTER TABLE customerbillingrecord DROP CONSTRAINT customerbillingrecord_customerbillingrecordcustomertypeuui_fkey;
ALTER TABLE customerbillingrecord DROP CONSTRAINT customerbillingrecord_customerbillingrecordbillingsystemuu_fkey;
ALTER TABLE entity.entitytemplate DROP CONSTRAINT entitytemplatemodifiedbyuuid_workerinstanceuuid_fk;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstraintconstrainedty_fkey;
ALTER TABLE entity.entityfield DROP CONSTRAINT entityfield_entityfieldmodifiedbyuuid_fkey;
ALTER TABLE worktemplatetype DROP CONSTRAINT worktemplatetype_worktemplatetypeworktemplateuuid_fkey;
ALTER TABLE worker DROP CONSTRAINT worker_workeridentitysystemuuid_fkey;
ALTER TABLE customerconfig DROP CONSTRAINT customerconfig_customerconfigcustomeruuid_fkey;
ALTER TABLE custag DROP CONSTRAINT custag_custagcustomeruuid_fkey;
ALTER TABLE customerbillingrecord DROP CONSTRAINT customerbillingrecord_customerbillingrecordmodifiedby_fkey;
ALTER TABLE worktemplatetype DROP CONSTRAINT worktemplatetype_worktemplatetypecustomeruuid_fkey;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstraintcustomeruuid_fkey;
ALTER TABLE customerconfig DROP CONSTRAINT customerconfig_customerconfigmodifiedby_fkey;
ALTER TABLE worker DROP CONSTRAINT worker_workerexternalsystemuuid_fkey;
ALTER TABLE customer DROP CONSTRAINT customer_customerexternalsystemuuid_fkey;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstraintconstraintid_fkey;
ALTER TABLE worktemplateconstraint DROP CONSTRAINT worktemplateconstraint_worktemplateconstrainttemplateid_fkey;
ALTER TABLE worktemplatetype DROP CONSTRAINT worktemplatetype_worktemplatetypesystaguuid_fkey;
ALTER TABLE apikey ALTER apikeyid DROP DEFAULT;
DROP VIEW view_activeworktemplatenexttemplate;
DROP VIEW view_worktemplate;
DROP VIEW view_workerinstance;
DROP VIEW view_activeworker;
DROP VIEW view_activeworkdescription;
DROP VIEW view_systag;
DROP VIEW view_location;
DROP VIEW view_activecustomerrequestedlanguage;
DROP VIEW view_activecustomer;
DROP VIEW view_custag;
DROP VIEW api.reason_code;
DROP VIEW api.location;
DROP VIEW view_workinstances_with_invalid_location;
DROP VIEW view_worktemplatenexttemplate;
DROP VIEW view_worker;
ALTER TABLE worker ALTER workergeneratedname DROP EXPRESSION;
DROP VIEW view_workdescription;
DROP VIEW view_customerrequestedlanguage;
DROP VIEW view_customer;
DROP TABLE registereddevice; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workresultinstance ALTER workresultinstancestartdatetz DROP EXPRESSION;
ALTER TABLE workresultinstance ALTER workresultinstancecompleteddatetz DROP EXPRESSION;
ALTER TABLE workresultinstance ALTER workresultinstancecreateddatetz DROP EXPRESSION;
ALTER TABLE workinstance ALTER workinstancetargetstartdatetz DROP EXPRESSION;
ALTER TABLE workinstance ALTER workinstancestartdatetz DROP EXPRESSION;
ALTER TABLE workinstance ALTER workinstancecompleteddatetz DROP EXPRESSION;
ALTER TABLE languagemaster ALTER languagemasterstatus DROP DEFAULT;
DROP TABLE languagemaster; --==>> !!! ATTENTION !!! <<==--
DROP VIEW api.customer_requested_language;
ALTER TABLE xtag ALTER xtagid DROP IDENTITY;
DROP TABLE xtag; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE xlabel ALTER xlabelid DROP IDENTITY;
DROP TABLE xlabel; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workweekexception ALTER workweekexceptionid DROP IDENTITY;
DROP TABLE workweekexception; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workweek ALTER workweekid DROP IDENTITY;
DROP TABLE workweek; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplateid DROP IDENTITY;
ALTER TABLE worktemplatedurationcalculation ALTER worktemplatedurationcalculationid DROP IDENTITY;
DROP TABLE worktemplatedurationcalculation; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE worktemplate ALTER worktemplateid DROP IDENTITY;
ALTER TABLE workresultcalculated ALTER workresultcalculatedid DROP IDENTITY;
ALTER TABLE workresult ALTER workresultid DROP IDENTITY;
ALTER TABLE workresource ALTER workresourceid DROP IDENTITY;
ALTER TABLE workpictureinstance ALTER workpictureinstanceid DROP IDENTITY;
DROP TABLE workpictureinstance; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workinstanceexception ALTER workinstanceexceptionid DROP IDENTITY;
DROP TABLE workinstanceexception; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workicon ALTER workiconid DROP IDENTITY;
DROP TABLE workicon; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workfrequencyhistory; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workfrequency ALTER workfrequencyid DROP IDENTITY;
ALTER TABLE workertemplatedurationcalculation ALTER workertemplatedurationcalculationid DROP IDENTITY;
DROP TABLE workertemplatedurationcalculation; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workerinstance ALTER workerinstanceid DROP IDENTITY;
ALTER TABLE worker ALTER workerid DROP IDENTITY;
ALTER TABLE workdescription ALTER workdescriptionid DROP IDENTITY;
DROP TABLE worktemplatetype; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workresultcalculated; --==>> !!! ATTENTION !!! <<==--
DROP TABLE worktemplatenexttemplate; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workresource; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workresult; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workfrequency; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workerinstance; --==>> !!! ATTENTION !!! <<==--
DROP TABLE worker; --==>> !!! ATTENTION !!! <<==--
DROP TABLE workdescription; --==>> !!! ATTENTION !!! <<==--
DROP TABLE "user"; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE systag ALTER systagid DROP IDENTITY;
DROP TABLE systag; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE resource ALTER resourceid DROP IDENTITY;
DROP TABLE resource; --==>> !!! ATTENTION !!! <<==--
DROP SEQUENCE IF EXISTS registereddevice_registereddeviceid_seq;
ALTER TABLE locationtemplatedurationcalculation ALTER locationtemplatedurationcalculationid DROP IDENTITY;
DROP TABLE locationtemplatedurationcalculation; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE location ALTER locationid DROP IDENTITY;
DROP TABLE location; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE languagetranslations ALTER languagetranslationid DROP IDENTITY;
ALTER TABLE languagemaster ALTER languagemasterid DROP IDENTITY;
ALTER TABLE invitationcode ALTER invitationcodeid DROP IDENTITY;
DROP TABLE invitationcode; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE initial_workinstance ALTER initialworkinstanceid DROP IDENTITY;
DROP TABLE initial_workinstance; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workresultinstance ALTER workresultinstanceid DROP IDENTITY;
DROP TABLE workresultinstance; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE workinstance ALTER workinstanceid DROP IDENTITY;
DROP TABLE workinstance; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE customer ALTER customerid DROP IDENTITY;
ALTER TABLE customerrequestedlanguage ALTER customerrequestedlanguageid DROP IDENTITY;
DROP TABLE customerconfig; --==>> !!! ATTENTION !!! <<==--
DROP TABLE customerbillingrecord; --==>> !!! ATTENTION !!! <<==--
DROP TABLE customer; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE custag ALTER custagid DROP IDENTITY;
DROP TABLE custag; --==>> !!! ATTENTION !!! <<==--
DROP SEQUENCE IF EXISTS apikey_apikeyid_seq;
DROP TABLE apikey; --==>> !!! ATTENTION !!! <<==--
ALTER TABLE address ALTER addressid DROP IDENTITY;
DROP TABLE address; --==>> !!! ATTENTION !!! <<==--
DROP TABLE _prisma_migrations; --==>> !!! ATTENTION !!! <<==--
DROP TABLE "_customerToregistereddevice"; --==>> !!! ATTENTION !!! <<==--
DROP FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text);
DROP FUNCTION zzz_crud_worker_list(text,text,text,bigint,text);
DROP PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint);
DROP PROCEDURE zzz_crud_site_update_v2(text,text,text,bigint,text,text,text,text,text,text,text,bigint);
DROP PROCEDURE zzz_crud_site_restart_v2(text,text,text,bigint,bigint);
DROP FUNCTION zzz_crud_site_read_v2(text,text,text,bigint,text);
DROP PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint);
DROP PROCEDURE zzz_crud_location_update_v2(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint);
DROP PROCEDURE zzz_crud_location_restart_v2(text,text,text,bigint,bigint);
DROP FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text);
DROP PROCEDURE zzz_crud_location_delete_v2(text,text,text,bigint,bigint);
DROP PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint);
DROP PROCEDURE zzz_crud_customer_restart_v2(text,text,text,bigint);
DROP FUNCTION zzz_crud_customer_read_v2(text,text,text);
DROP PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint);
DROP FUNCTION zzz_crud_customer_config_templates_list_v2(bigint);
DROP FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint);
DROP PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text);
DROP FUNCTION superset_timesheet_missingclockin(text,integer,date);
DROP FUNCTION func_timesheet_override_bigint(bigint,date);
DROP FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]);
DROP FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean);
DROP FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean);
DROP FUNCTION func_read_workresultinstancevalues_bigint(text[],text,text,boolean);
DROP FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]);
DROP FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]);
DROP FUNCTION func_read_rtls_last_known_location(timestamp with time zone,text[],text[],text[]);
DROP FUNCTION enable_runtime(text,text,text,bigint,text);
DROP FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint);
DROP PROCEDURE crud_timesheet_enable_customer(text,text,bigint);
DROP FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint);
DROP FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint);
DROP PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint);
DROP PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint);
DROP PROCEDURE crud_site_restart(text,text,text,bigint,bigint);
DROP FUNCTION crud_site_read(text,text,text,bigint,text);
DROP PROCEDURE crud_site_delete(text,text,text,bigint,bigint);
DROP PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint);
DROP PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint);
DROP PROCEDURE crud_rtls_create_customer(text,text,text,bigint);
DROP PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint);
DROP PROCEDURE crud_location_restart(text,text,text,bigint,bigint);
DROP FUNCTION crud_location_read(text,text,text,bigint,text);
DROP PROCEDURE crud_location_delete(text,text,text,bigint,bigint);
DROP PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint);
DROP FUNCTION crud_language_list(bigint);
DROP PROCEDURE crud_customer_update(text,text,text,text,text,bigint);
DROP PROCEDURE crud_customer_restart(text,text,text,bigint);
DROP FUNCTION crud_customer_read(text,text,text);
DROP PROCEDURE crud_customer_metering_query(integer,integer,text);
DROP PROCEDURE crud_customer_delete(text,text,text,bigint);
DROP PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint);
DROP PROCEDURE crud_customer_config_update(text,text,text,text);
DROP FUNCTION crud_customer_config_templates_list(bigint);
DROP FUNCTION crud_customer_config_list(text,bigint);
DROP PROCEDURE crud_customer_config_delete(text,text,text);
DROP PROCEDURE crud_customer_config_create(text,text,text,text,text);
DROP PROCEDURE crud_customer_config_activate(text,text,text);
DROP PROCEDURE crud_checklist_create_customer(text,text,text,bigint);
DROP PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint);
DROP FUNCTION create_location(text,bigint,text,text,text,text,text);
DROP FUNCTION check_workresult_name();
DROP PROCEDURE backfill_swiss_army_knife();
DROP PROCEDURE backfill_billing_tendrel();
DROP PROCEDURE alarm_orphanedtask();
DROP PROCEDURE alarm_orphanedondemand();
DROP FUNCTION alarm_missingexpirationdate_details();
DROP PROCEDURE alarm();
DROP TABLE worktemplateconstraint; --==>> !!! ATTENTION !!! <<==--
DROP TABLE worktemplate; --==>> !!! ATTENTION !!! <<==--
DROP TABLE languagetranslations; --==>> !!! ATTENTION !!! <<==--
DROP TABLE customerrequestedlanguage; --==>> !!! ATTENTION !!! <<==--
DROP TYPE "TranslationStatus";
DROP TYPE "Platform";
DROP TYPE "DeviceType";
DROP EXTENSION uuid-ossp;

DROP SCHEMA public;
*/

CREATE SCHEMA public;
COMMENT ON SCHEMA public IS 'standard public schema';

ALTER SCHEMA public OWNER TO pg_database_owner;
GRANT USAGE ON SCHEMA public TO graphql;
GRANT USAGE ON SCHEMA public TO PUBLIC;

-- DEPENDANTS

CREATE EXTENSION "uuid-ossp" VERSION '1.1';
COMMENT ON EXTENSION uuid-ossp IS 'generate universally unique identifiers (UUIDs)';

CREATE TYPE "DeviceType" AS ENUM (
 'MOBILE',
 'TABLET',
 'IOT',
 'WEB'
);


CREATE TYPE "Platform" AS ENUM (
 'ANDROID',
 'IOS'
);


CREATE TYPE "TranslationStatus" AS ENUM (
 'NEEDS_TRANSLATION',
 'IN_PROGRESS',
 'DONE',
 'FAILED',
 'NEEDS_COMPLETE_RETRANSLATION',
 'NEVER_TRANSLATE'
);



-- Type: TABLE ; Name: customerrequestedlanguage; Owner: tendreladmin

CREATE TABLE customerrequestedlanguage (
    customerrequestedlanguageid bigint GENERATED ALWAYS AS IDENTITY,
    customerrequestedlanguagecustomerid bigint NOT NULL,
    customerrequestedlanguagelanguageid bigint NOT NULL,
    customerrequestedlanguagestartdate timestamp(3) with time zone,
    customerrequestedlanguageenddate timestamp(3) with time zone,
    customerrequestedlanguagecreateddate timestamp(3) with time zone NOT NULL,
    customerrequestedlanguagemodifieddate timestamp(3) with time zone NOT NULL,
    customerrequestedlanguageexternalid text,
    customerrequestedlanguageexternalsystemid bigint,
    customerrequestedlanguagemodifiedby bigint,
    customerrequestedlanguagerefid bigint,
    customerrequestedlanguagesystemid bigint,
    customerrequestedlanguageuuid text NOT NULL
);


ALTER TABLE customerrequestedlanguage ALTER customerrequestedlanguagestartdate SET DEFAULT now();
ALTER TABLE customerrequestedlanguage ALTER customerrequestedlanguagecreateddate SET DEFAULT now();
ALTER TABLE customerrequestedlanguage ALTER customerrequestedlanguagemodifieddate SET DEFAULT now();
ALTER TABLE customerrequestedlanguage ALTER customerrequestedlanguageuuid SET DEFAULT concat('crl_', gen_random_uuid());

ALTER TABLE customerrequestedlanguage ADD CONSTRAINT customerrequestedlanguage_pkey PRIMARY KEY (customerrequestedlanguageid);
ALTER TABLE customerrequestedlanguage ADD CONSTRAINT customerid_fkey FOREIGN KEY (customerrequestedlanguagecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE customerrequestedlanguage ADD CONSTRAINT customerrequestedlanguage_customerrequestedlanguagemodifie_fkey FOREIGN KEY (customerrequestedlanguagemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customerrequestedlanguage ADD CONSTRAINT systag_fkey FOREIGN KEY (customerrequestedlanguagelanguageid) REFERENCES systag(systagid);

CREATE INDEX customerrequestedlanguage_customerrequestedlanguagecustomer_idx ON public.customerrequestedlanguage USING btree (customerrequestedlanguagecustomerid);
CREATE UNIQUE INDEX customerrequestedlanguage_customerrequestedlanguagecustomer_key ON public.customerrequestedlanguage USING btree (customerrequestedlanguagecustomerid, customerrequestedlanguagelanguageid);
CREATE UNIQUE INDEX customerrequestedlanguage_customerrequestedlanguageuuid_key ON public.customerrequestedlanguage USING btree (customerrequestedlanguageuuid);

GRANT INSERT ON customerrequestedlanguage TO authenticated;
GRANT SELECT ON customerrequestedlanguage TO authenticated;
GRANT UPDATE ON customerrequestedlanguage TO authenticated;
GRANT DELETE ON customerrequestedlanguage TO graphql;
GRANT INSERT ON customerrequestedlanguage TO graphql;
GRANT REFERENCES ON customerrequestedlanguage TO graphql;
GRANT SELECT ON customerrequestedlanguage TO graphql;
GRANT TRIGGER ON customerrequestedlanguage TO graphql;
GRANT TRUNCATE ON customerrequestedlanguage TO graphql;
GRANT UPDATE ON customerrequestedlanguage TO graphql;

-- Type: TABLE ; Name: languagetranslations; Owner: tendreladmin

CREATE TABLE languagetranslations (
    languagetranslationid bigint GENERATED ALWAYS AS IDENTITY,
    languagetranslationcustomerid bigint,
    languagetranslationcustomersiteid bigint,
    languagetranslationmasterid bigint NOT NULL,
    languagetranslationtypeid bigint NOT NULL,
    languagetranslationvalue text NOT NULL,
    languagetranslationcreateddate timestamp(3) with time zone NOT NULL,
    languagetranslationmodifieddate timestamp(3) with time zone NOT NULL,
    languagetranslationisoverride boolean NOT NULL,
    languagetranslationexternalid text,
    languagetranslationexternalsystemid bigint,
    languagetranslationmodifiedby bigint,
    languagetranslationrefid bigint,
    languagetranslationuuid text NOT NULL
);


ALTER TABLE languagetranslations ALTER languagetranslationcreateddate SET DEFAULT now();
ALTER TABLE languagetranslations ALTER languagetranslationmodifieddate SET DEFAULT now();
ALTER TABLE languagetranslations ALTER languagetranslationisoverride SET DEFAULT false;
ALTER TABLE languagetranslations ALTER languagetranslationuuid SET DEFAULT concat('lt_', gen_random_uuid());

ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_pkey PRIMARY KEY (languagetranslationid);
ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationcustomerid_fkey FOREIGN KEY (languagetranslationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationcustomersiteid_fkey FOREIGN KEY (languagetranslationcustomersiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationmasterid_fkey FOREIGN KEY (languagetranslationmasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationmodifiedby_fkey FOREIGN KEY (languagetranslationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationtypeid_fkey FOREIGN KEY (languagetranslationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX languagetranslations_languagetranslationcustomerid_idx ON public.languagetranslations USING btree (languagetranslationcustomerid);
CREATE UNIQUE INDEX languagetranslations_languagetranslationcustomerid_language_key ON public.languagetranslations USING btree (languagetranslationcustomerid, languagetranslationmasterid, languagetranslationtypeid);
CREATE INDEX languagetranslations_languagetranslationmasterid_idx ON public.languagetranslations USING btree (languagetranslationmasterid);
CREATE UNIQUE INDEX languagetranslations_languagetranslationmasterid_languagetr_key ON public.languagetranslations USING btree (languagetranslationmasterid, languagetranslationtypeid);
CREATE INDEX languagetranslations_languagetranslationtypeid_idx ON public.languagetranslations USING btree (languagetranslationtypeid);
CREATE UNIQUE INDEX languagetranslations_languagetranslationuuid_key ON public.languagetranslations USING btree (languagetranslationuuid);

GRANT INSERT ON languagetranslations TO authenticated;
GRANT SELECT ON languagetranslations TO authenticated;
GRANT UPDATE ON languagetranslations TO authenticated;
GRANT DELETE ON languagetranslations TO graphql;
GRANT INSERT ON languagetranslations TO graphql;
GRANT REFERENCES ON languagetranslations TO graphql;
GRANT SELECT ON languagetranslations TO graphql;
GRANT TRIGGER ON languagetranslations TO graphql;
GRANT TRUNCATE ON languagetranslations TO graphql;
GRANT UPDATE ON languagetranslations TO graphql;

-- Type: TABLE ; Name: worktemplate; Owner: tendreladmin

CREATE TABLE worktemplate (
    worktemplateid bigint GENERATED ALWAYS AS IDENTITY,
    worktemplatecustomerid bigint NOT NULL,
    worktemplatestartdate timestamp(3) with time zone,
    worktemplateenddate timestamp(3) with time zone,
    worktemplatecreateddate timestamp(3) with time zone NOT NULL,
    worktemplatemodifieddate timestamp(3) with time zone NOT NULL,
    worktemplateexpectedduration bigint,
    worktemplateexpecteddurationtypeid bigint,
    worktemplatesiteid bigint NOT NULL,
    worktemplatelocationtypeid bigint,
    worktemplateexternalsystemid bigint,
    worktemplateexternalid text,
    worktemplatescanid text,
    worktemplatesoplink text,
    worktemplatenameid bigint NOT NULL,
    worktemplateneedstranslation boolean,
    id text NOT NULL,
    worktemplateorder integer NOT NULL,
    worktemplateallowondemand boolean NOT NULL,
    worktemplatedescriptionid bigint,
    worktemplateworkfrequencyid bigint NOT NULL,
    worktemplateisauditable boolean NOT NULL,
    worktemplatemodifiedby bigint,
    worktemplaterefid bigint,
    worktemplaterefuuid text,
    worktemplatereapinprogauditmillis bigint,
    worktemplatereapinprogworkmillis bigint,
    worktemplatereapopenauditmillis bigint,
    worktemplatereapopenworkmillis bigint,
    worktemplatedeleted boolean NOT NULL,
    worktemplatedraft boolean NOT NULL
);


ALTER TABLE worktemplate ALTER worktemplatestartdate SET DEFAULT now();
ALTER TABLE worktemplate ALTER worktemplatecreateddate SET DEFAULT now();
ALTER TABLE worktemplate ALTER worktemplatemodifieddate SET DEFAULT now();
ALTER TABLE worktemplate ALTER worktemplateneedstranslation SET DEFAULT true;
ALTER TABLE worktemplate ALTER id SET DEFAULT concat('work-template_', gen_random_uuid());
ALTER TABLE worktemplate ALTER worktemplateorder SET DEFAULT 1;
ALTER TABLE worktemplate ALTER worktemplateallowondemand SET DEFAULT false;
ALTER TABLE worktemplate ALTER worktemplateisauditable SET DEFAULT false;
ALTER TABLE worktemplate ALTER worktemplatedeleted SET DEFAULT false;
ALTER TABLE worktemplate ALTER worktemplatedraft SET DEFAULT false;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_pkey PRIMARY KEY (worktemplateid);
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatecustomerid_fkey FOREIGN KEY (worktemplatecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatedescriptionid_fkey FOREIGN KEY (worktemplatedescriptionid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplateexpecteddurationtypeid_fkey FOREIGN KEY (worktemplateexpecteddurationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatelocationtypeid_fkey FOREIGN KEY (worktemplatelocationtypeid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatemodifiedby_fkey FOREIGN KEY (worktemplatemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatenameid_fkey FOREIGN KEY (worktemplatenameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatesiteid_fkey FOREIGN KEY (worktemplatesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplateworkfrequencyid_fkey FOREIGN KEY (worktemplateworkfrequencyid) REFERENCES workfrequency(workfrequencyid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX worktemplate_id_key ON public.worktemplate USING btree (id);
CREATE INDEX worktemplate_worktemplatedeleted_idx ON public.worktemplate USING btree (worktemplatedeleted);
CREATE INDEX worktemplate_worktemplatedraft_idx ON public.worktemplate USING btree (worktemplatedraft);
CREATE INDEX worktemplateidandenddate_idx ON public.worktemplate USING btree (worktemplateid, worktemplateenddate);
CREATE INDEX worktemplateisauditable_idx ON public.worktemplate USING btree (worktemplateid, worktemplateisauditable);

GRANT INSERT ON worktemplate TO authenticated;
GRANT SELECT ON worktemplate TO authenticated;
GRANT UPDATE ON worktemplate TO authenticated;
GRANT DELETE ON worktemplate TO graphql;
GRANT INSERT ON worktemplate TO graphql;
GRANT REFERENCES ON worktemplate TO graphql;
GRANT SELECT ON worktemplate TO graphql;
GRANT TRIGGER ON worktemplate TO graphql;
GRANT TRUNCATE ON worktemplate TO graphql;
GRANT UPDATE ON worktemplate TO graphql;

-- Type: TABLE ; Name: worktemplateconstraint; Owner: tendreladmin

CREATE TABLE worktemplateconstraint (
    worktemplateconstraintid text NOT NULL,
    worktemplateconstraintcreateddate timestamp(3) without time zone NOT NULL,
    worktemplateconstraintmodifieddate timestamp(3) without time zone NOT NULL,
    worktemplateconstraintmodifiedby bigint,
    worktemplateconstraintrefid bigint,
    worktemplateconstraintrefuuid text,
    worktemplateconstraintconstrainedtypeid text NOT NULL,
    worktemplateconstraintconstraintid text NOT NULL,
    worktemplateconstrainttemplateid text NOT NULL,
    worktemplateconstraintresultid text,
    worktemplateconstraintcustomerid bigint NOT NULL,
    worktemplateconstraintcustomeruuid text
);


ALTER TABLE worktemplateconstraint ALTER worktemplateconstraintid SET DEFAULT concat('work-template-constraint_', gen_random_uuid());
ALTER TABLE worktemplateconstraint ALTER worktemplateconstraintcreateddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE worktemplateconstraint ALTER worktemplateconstraintmodifieddate SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_pkey PRIMARY KEY (worktemplateconstraintid);
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintconstrainedty_fkey FOREIGN KEY (worktemplateconstraintconstrainedtypeid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintconstraintid_fkey FOREIGN KEY (worktemplateconstraintconstraintid) REFERENCES custag(custaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintcustomerid_fkey FOREIGN KEY (worktemplateconstraintcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintcustomeruuid_fkey FOREIGN KEY (worktemplateconstraintcustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintmodifiedby_fkey FOREIGN KEY (worktemplateconstraintmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintresultid_fkey FOREIGN KEY (worktemplateconstraintresultid) REFERENCES workresult(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstrainttemplateid_fkey FOREIGN KEY (worktemplateconstrainttemplateid) REFERENCES worktemplate(id) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX temp_wtc_with_result_idx ON public.worktemplateconstraint USING btree (worktemplateconstraintcustomerid, worktemplateconstrainttemplateid, worktemplateconstraintresultid, worktemplateconstraintconstrainedtypeid, worktemplateconstraintconstraintid) WHERE (worktemplateconstraintresultid IS NOT NULL);
CREATE UNIQUE INDEX temp_wtc_without_result_idx ON public.worktemplateconstraint USING btree (worktemplateconstraintcustomerid, worktemplateconstrainttemplateid, worktemplateconstraintconstrainedtypeid, worktemplateconstraintconstraintid) WHERE (worktemplateconstraintresultid IS NULL);
CREATE INDEX worktemplateconstraint_worktemplateconstrainttemplateid_idx ON public.worktemplateconstraint USING btree (worktemplateconstrainttemplateid);

GRANT INSERT ON worktemplateconstraint TO authenticated;
GRANT SELECT ON worktemplateconstraint TO authenticated;
GRANT UPDATE ON worktemplateconstraint TO authenticated;
GRANT DELETE ON worktemplateconstraint TO graphql;
GRANT INSERT ON worktemplateconstraint TO graphql;
GRANT REFERENCES ON worktemplateconstraint TO graphql;
GRANT SELECT ON worktemplateconstraint TO graphql;
GRANT TRIGGER ON worktemplateconstraint TO graphql;
GRANT TRUNCATE ON worktemplateconstraint TO graphql;
GRANT UPDATE ON worktemplateconstraint TO graphql;

-- Type: PROCEDURE ; Name: alarm(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.alarm()
 LANGUAGE plpgsql
AS $procedure$
Declare
   alarm_start timestamp with time zone;
Begin

-- Start the timer on this function
	alarm_start = clock_timestamp();

	CALL datawarehouse.alarm();

Commit;

if  (select dwlogginglevel1 from datawarehouse.dw_logginglevels) = false
	Then Return;
end if;

-- Insert into the tendy tracker
--call datawarehouse.insert_tendy_tracker(0, 1378, 12496, 811, 844, 12341, 18068, 12846,12340, import_start);

COMMIT; 
End;

$procedure$;


REVOKE ALL ON PROCEDURE alarm() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm() TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: alarm_missingexpirationdate_details(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.alarm_missingexpirationdate_details()
 RETURNS TABLE(workinstancecustomerid bigint, workinstancesiteid bigint, workinstanceworktemplateid bigint, workinstanceid bigint, workinstancepreviousid bigint)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

DECLARE
    tempcustomerid bigint;
    startdate      timestamp WITH TIME ZONE;

BEGIN

    startdate = (SELECT (MAX(workinstancemodifieddate) - INTERVAL '4 day') AS startdate FROM workinstance);

    RETURN QUERY
        (SELECT wi.workinstancecustomerid,
                wi.workinstancesiteid,
                wi.workinstanceworktemplateid,
                wi.workinstanceid,
                wi.workinstancepreviousid
         FROM public.workinstance wi
                  INNER JOIN public.worktemplatetype wtt
                             ON wtt.worktemplatetypeworktemplateid = wi.workinstanceworktemplateid
         WHERE wi.workinstancestatusid = 707
           AND wtt.worktemplatetypesystaguuid not in ('systag_cbe3ebc9-2d91-4647-beab-9807657c717a', 'ad2f2ced-06ca-46ab-8d75-a2c0a97ad33d')  -- not checklist or runtime
           AND wi.workinstanceexpirationdate ISNULL
           AND workinstancemodifieddate > startdate
           AND workinstancemodifieddate < NOW() - INTERVAL '5 minute');

END;

$function$;


REVOKE ALL ON FUNCTION alarm_missingexpirationdate_details() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION alarm_missingexpirationdate_details() TO PUBLIC;
GRANT EXECUTE ON FUNCTION alarm_missingexpirationdate_details() TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: alarm_orphanedondemand(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.alarm_orphanedondemand(OUT tempcount bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   orphanedtask_start timestamp with time zone;  
   notestext text;
Begin
	orphanedtask_start = clock_timestamp();
	
-- Get the templates that should have workinstances

create temp table temptemplate as 
(
	SELECT wt.*
	FROM worktemplate AS wt	
		inner join workfrequency wf
			ON wt.worktemplateworkfrequencyid = wf.workfrequencyid
				and workfrequencytypeid <> 748
	where wt.worktemplateallowondemand = TRUE
		AND (wt.worktemplateenddate IS NULL
					OR wt.worktemplateenddate > NOW())	
);

-- Join this list to the location table and remove exceptions

create temp table tempwi as 
select wt.*, loc.*
from temptemplate wt
	INNER JOIN location AS loc
		ON wt.worktemplatelocationtypeid = loc.locationcategoryid
			AND wt.worktemplatesiteid = loc.locationsiteid
			AND (loc.locationenddate IS NULL
				OR loc.locationenddate > NOW())
	left join workinstanceexception AS wie
		on wt.worktemplatecustomerid = wie.workinstanceexceptioncustomerid
			AND wt.worktemplateid = wie.workinstanceexceptionworktemplateid
			AND wt.worktemplatesiteid = wie.workinstanceexceptionsiteid
			AND loc.locationid = wie.workinstanceexceptionlocationid
where wie.workinstanceexceptionid isNull;

tempcount = (select count(*) 
			from tempwi
				left join view_workinstance_full wi
					on workinstanceworktemplateid = worktemplateid
							AND workinstancestatusid in (706,707)
							AND wi.workinstancetypeid = 811
			where workinstanceid isNull);

--if  (select dwlogginglevel2 from datawarehouse.dw_logginglevels) = true
--	Then 
	call datawarehouse.insert_tendy_tracker(0, 1426, 12496, 811, 844, 14295, 18068, 14296,14294, orphanedtask_start);
--end if;


RAISE NOTICE 'count: %', tempcount;

if  tempcount = 0
	THEN drop table temptemplate;
		 drop table tempwi;
		 Return;
end if;

notestext = (
			select 'count: '||tempcount::text||', (worktemplateid,locationid), '||string_agg (teststring,', ') as orphans
			from (select worktemplatecustomerid, 
					'('||worktemplateid::text||','|| locationid::text||')' as teststring
				from tempwi
					left join view_workinstance_full wi
						on workinstanceworktemplateid = worktemplateid
								AND workinstancestatusid in (706,707)
								AND wi.workinstancetypeid = 811
				where workinstanceid isNull) as test
			group by worktemplatecustomerid
			);
			 
drop table temptemplate;
drop table tempwi;

-- cheating and prefilling the notes on the remediation.
-- may want to uniquely name the workinstnace as well
-- may also want to check to see if there is already a remediation open

call datawarehouse.insert_tendy_remediation(0, 1427, 12496, 694, 18068, 14299, notestext,14300 ,orphanedtask_start);


End;

$procedure$;


REVOKE ALL ON PROCEDURE alarm_orphanedondemand() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm_orphanedondemand() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm_orphanedondemand() TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: alarm_orphanedtask(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.alarm_orphanedtask(OUT tempcount bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   orphanedtask_start timestamp with time zone;  
   notestext text;
Begin
	orphanedtask_start = clock_timestamp();
	
-- Get the templates that should have workinstances

create temp table temptemplate as 
(
	SELECT wt.*
	FROM worktemplate AS wt	
		inner join workfrequency wf
			ON wt.worktemplateworkfrequencyid = wf.workfrequencyid
				and workfrequencytypeid <> 748
	 	left join worktemplatenexttemplate wtnt
			on wt.worktemplateid = wtnt.worktemplatenexttemplatenexttemplateid	
	where wtnt.worktemplatenexttemplateid isNull 
		AND wt.worktemplateallowondemand = FALSE
		AND (wt.worktemplateenddate IS NULL
					OR wt.worktemplateenddate > NOW())	
);

-- Join this list to the location table and remove exceptions

create temp table tempwi as 
select wt.*, loc.*
from temptemplate wt
	INNER JOIN location AS loc
		ON wt.worktemplatelocationtypeid = loc.locationcategoryid
			AND wt.worktemplatesiteid = loc.locationsiteid
			AND (loc.locationenddate IS NULL
				OR loc.locationenddate > NOW())
	left join workinstanceexception AS wie
		on wt.worktemplatecustomerid = wie.workinstanceexceptioncustomerid
			AND wt.worktemplateid = wie.workinstanceexceptionworktemplateid
			AND wt.worktemplatesiteid = wie.workinstanceexceptionsiteid
			AND loc.locationid = wie.workinstanceexceptionlocationid
where wie.workinstanceexceptionid isNull;

tempcount = (select count(*) 
			from tempwi
				left join view_workinstance_full wi
					on workinstanceworktemplateid = worktemplateid
							AND workinstancestatusid in (706,707)
							AND wi.workinstancetypeid = 692
			where workinstanceid isNull);

--if  (select dwlogginglevel2 from datawarehouse.dw_logginglevels) = true
--	Then 
	call datawarehouse.insert_tendy_tracker(0, 1424, 12496, 811, 844, 14287, 18068, 14288,14286, orphanedtask_start);
--end if;

RAISE NOTICE 'count: %', tempcount;

if  tempcount = 0
	THEN drop table temptemplate;
		 drop table tempwi;
		 Return;
end if;

notestext = (
			select 'count: '||tempcount::text||', (worktemplateid,locationid), '||string_agg (teststring,', ') as orphans
			from (select worktemplatecustomerid, 
					'('||worktemplateid::text||','|| locationid::text||')' as teststring
				from tempwi
					left join view_workinstance_full wi
						on workinstanceworktemplateid = worktemplateid
								AND workinstancestatusid in (706,707)
								AND wi.workinstancetypeid = 692
				where workinstanceid isNull) as test
			group by worktemplatecustomerid
			);
			 
drop table temptemplate;
drop table tempwi;

-- cheating and prefilling the notes on the remediation.
-- may want to uniquely name the workinstnace as well
-- may also want to check to see if there is already a remediation open

call datawarehouse.insert_tendy_remediation(0, 1425, 12496, 694, 18068, 14291, notestext,14292 ,orphanedtask_start);


End;

$procedure$;


REVOKE ALL ON PROCEDURE alarm_orphanedtask() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm_orphanedtask() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm_orphanedtask() TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: backfill_billing_tendrel(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.backfill_billing_tendrel()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	customer_uuid record;
	config_id text;
	tempmodifiedby text;
	tempcustomeruuid text;
	tempsiteuuid text;
BEGIN

tempmodifiedby = (select workerinstanceuuid from workerinstance where workerinstanceid = 337);
tempcustomeruuid = (select customeruuid from customer where customerid = 0);
tempsiteuuid = (select locationuuid from location where locationcustomerid = 0 and locationistop = true);
	
-- Add all customer not cust 0 or 
FOR customer_uuid in (
	select customeruuid from customer where customerid <> 0 
	)
loop
	raise notice 'customer: %', customer_uuid.customeruuid;
	call public.crud_customer_config_create(
		customer_uuid.customeruuid, 
		-- Leaving site null
		null::text,
		-- customer config template uuid for 'Billing :: Tendrel'
		'customerconfig_0ba355c2-e93d-449d-8e04-97395b30b7b7'::text,
		'true'::text, 
		-- modified by Mark
		tempmodifiedby,
		config_id
);
end loop;


-- Add cust 0
call public.crud_customer_config_create(
	tempcustomeruuid, 
	-- cust 0 site id
	tempsiteuuid,
	-- customer config template uuid for 'Billing :: Tendrel'
	'customerconfig_0ba355c2-e93d-449d-8e04-97395b30b7b7'::text,
	'true'::text, 
	-- modified by Mark
	tempmodifiedby,
	config_id);


END;
$procedure$;


REVOKE ALL ON PROCEDURE backfill_billing_tendrel() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_billing_tendrel() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_billing_tendrel() TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: backfill_swiss_army_knife(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.backfill_swiss_army_knife()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	customer_uuid record;
	config_id text;
BEGIN

FOR customer_uuid in (
	select customeruuid from customer
)
loop
	raise notice 'customer: %', customer_uuid.customeruuid;
	call public.crud_customer_config_create(
		customer_uuid.customeruuid, 
		-- Leaving site null
		null,
		-- customer config template uuid for 'Applications :: Tendrel'
		'customerconfig_438370f8-6d76-454c-9337-de7ad08a7e32'::text,
		'true'::text, 
		-- modified by Fede
		'worker-instance_8cd9e1fb-7b6e-48f2-b5d8-8d9f54381160'::text,
		config_id
);
end loop;
END;
$procedure$;


REVOKE ALL ON PROCEDURE backfill_swiss_army_knife() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_swiss_army_knife() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_swiss_army_knife() TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: check_workresult_name(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.check_workresult_name()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
  BEGIN
      IF EXISTS (
          SELECT workresultworktemplateid, workresultisprimary, languagemastersource, count(*)
          FROM workresult
          INNER JOIN languagemaster
              ON
                  workresultlanguagemasterid = languagemasterid
          WHERE
              workresultcustomerid = NEW.workresultcustomerid
              AND workresultworktemplateid = NEW.workresultworktemplateid
          GROUP BY workresultworktemplateid, workresultisprimary, languagemastersource
          HAVING count(*) > 1
      ) THEN
          RAISE NOTICE 'workresultlanguagemasterid: % already exists on worktemplateid: %', NEW.workresultlanguagemasterid, NEW.workresultworktemplateid;
          RAISE unique_violation USING MESSAGE = 'workresult name must be unique within a customer/template';
      END IF;

      RETURN NULL; -- return value ignore for AFTER triggers
  END
$function$;


REVOKE ALL ON FUNCTION check_workresult_name() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION check_workresult_name() TO PUBLIC;
GRANT EXECUTE ON FUNCTION check_workresult_name() TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: create_location(text,bigint,text,text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.create_location(customer_id text, modified_by bigint, language_type text, timezone text, location_name text, location_parent_id text, location_typename text)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    select *
    from legacy0.create_location(
        customer_id := customer_id,
        language_type := language_type,
        location_name := location_name,
        location_parent_id := location_parent_id,
        location_timezone := timezone,
        location_typename := location_typename,
        modified_by := modified_by
    );

  return;
end
$function$;


REVOKE ALL ON FUNCTION create_location(text,bigint,text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION create_location(text,bigint,text,text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION create_location(text,bigint,text,text,text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.create_rtlsinstances(IN create_customeruuid text, IN create_locationuuid text, IN create_workerinstanceuuid text, IN create_localuuid text, IN create_previouslocaluuid text, IN create_rtlsactivitytype text, IN create_createddate numeric, IN create_onlinestatus text, IN create_accuracy numeric, IN create_altitude numeric, IN create_altitudeaccuracy numeric, IN create_heading numeric, IN create_latitude numeric, IN create_longitude numeric, IN create_speed numeric, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempsiteid bigint;
	templocationid bigint;
	temptemplateid bigint;
	tempworkinstanceid bigint;
	tempworkerinstanceid bigint;
	temppreviousid  bigint;
	tempdate timestamp with time zone;
	temptz text;
	tempresultid  bigint;

Begin

-- Future - insert CheckIn/Out
-- Future RTLS tempalte is a a new task type

tempcustomerid = (select customerid
					from customer
					where customeruuid = create_customeruuid);

tempsiteid = (select locationsiteid
					from location
					where locationcustomerid = tempcustomerid
						and locationuuid = create_locationuuid);

templocationid = (select locationid
					from location
					where locationcustomerid = tempcustomerid
						and locationuuid = create_locationuuid);

-- Future - Add guardrails if tempcustomerid isNull

-- Find RTLS template for this customer.

temptemplateid = (select worktemplateid
					from worktemplate
						inner join public.worktemplatetype
							on worktemplateid = worktemplatetypeworktemplateid
								and worktemplatetypesystaguuid = (select systaguuid
																	from systag
																	where systaguuid = 'f0d0bca1-827a-46da-80bc-af1c8ef914db'  )
					where worktemplatecustomerid = tempcustomerid
						and worktemplatesiteid = tempsiteid);

tempdate = (SELECT to_timestamp( TRUNC(create_createddate/ 1000)));

temppreviousid = (select workinstanceid
					from workinstance
					where workinstancecustomerid = tempcustomerid
						and  workinstanceexternalid = create_previouslocaluuid);

tempworkerinstanceid = (select workerinstanceid
							from workerinstance
							where workerinstanceuuid =  create_workerinstanceuuid);


temptz = (select locationtimezone from location where locationid = tempsiteid);

-- Futue proof this checking to see if the wi already exists.

INSERT INTO public.workinstance(
	workinstancecustomerid,
	workinstanceworktemplateid,
	workinstancesiteid,
	workinstancetypeid,
	workinstancestatusid,
	workinstancetargetstartdate,
	workinstancestartdate,
	workinstancecompleteddate,
	workinstanceexternalid,
	workinstancetimezone,
	workinstancepreviousid,
	workinstancemodifiedby)
values (
 	tempcustomerid,
	temptemplateid,
	tempsiteid,
	811,
	710,
	tempdate,
	tempdate,
	tempdate,
	create_localuuid,
	temptz,
	temppreviousid,
 	create_modifiedbyid) ;

tempworkinstanceid = (select workinstanceid from workinstance where workinstanceexternalid = create_localuuid );
-- insert primary location

tempresultid = (select workresultid
				from workresult
				where workresultworktemplateid = temptemplateid
					and workresultentitytypeid = 852
		 			and workresultisprimary = true);

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	templocationid,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert primary worker

tempresultid = (select workresultid
				from workresult
				where workresultworktemplateid = temptemplateid
					and workresultentitytypeid = 850
		 			and workresultisprimary = true);

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	tempworkerinstanceid,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert TAT

tempresultid = (select workresultid
				from workresult
				where workresultworktemplateid = temptemplateid
					and workresulttypeid = 737);

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	1,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert tendrel version geo info -- Future work

-- insert 'RTLS - Online Status'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Online Status');

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_onlinestatus,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Accuracy'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Accuracy') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_accuracy,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Altitude'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Altitude') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_altitude,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Altitude Accuracy'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Altitude Accuracy') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_altitudeAccuracy,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Heading'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Heading') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_heading,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Latitude'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Latitude') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_latitude,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Longitude'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Longitude') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_longitude,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Speed'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Speed') ;

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstancevalue,
	workresultinstancecreateddate,
	workresultinstancemodifieddate,
	workresultinstancestartdate,
	workresultinstancecompleteddate,
	workresultinstanceworkresultid,
	workresultinstanceexternalid,
	workresultinstancevaluelanguagetypeid,
	workresultinstancemodifiedby,
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_speed,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

update public.workinstance
set workinstanceoriginatorworkinstanceid = tempworkinstanceid,
	workinstancemodifieddate = clock_timestamp()
where workinstanceid = tempworkinstanceid;

--RAISE NOTICE 'instance loaded';

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_checklist_create_customer(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_checklist_create_customer(IN create_customeruuid text, IN create_siteuuid text, OUT create_adminuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
-- Customer temp values
    tempcustomerid                 bigint := (SELECT customerid
                                              FROM customer
                                              WHERE customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp values
    tempcustagsitetypeid           bigint;
    tempsiteid                     bigint := (SELECT locationid
                                              FROM location
                                              WHERE locationuuid = create_siteuuid);
    tempsiteuuid                   text;
    tempsitename                   text   := (SELECT locationlookupname
                                              FROM view_location
                                              WHERE locationuuid = create_siteuuid
                                                AND languagetranslationtypeid = 20);
    tempcustagsitetypeuuid         text   := (SELECT custaguuid
                                              FROM custag
                                                       INNER JOIN customer
                                                                  ON custagcustomerid = customerid
                                              WHERE custagtype = tempsitename
                                                AND (create_customeruuid = custagcustomeruuid
                                                  OR tempcustomerid = custagcustomerid));
    tempsitelanguagemasterid       bigint;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
    template_description_id        bigint;
    long_text_default_value_id     bigint;
-- checklist
    checklist_config_template_uuid text;
    checklist_config_uuid          text;

BEGIN
/*
    RAISE NOTICE 'Start of procedure';

    IF (SELECT EXISTS(SELECT id
                      FROM view_worktemplate
                      WHERE worktemplatename = 'Demo Checklist'
                        AND worktemplatecustomerid = tempcustomerid)) THEN
        RAISE NOTICE 'Checklist template exists, skipping.';
    ELSE
        -- Add in worktemplates for the site id and location types
-- Add in checklist template type

        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'Demo Checklist',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'Use the Tendrel Console to modify this demo checklist or create your own!',
                create_modifiedby)
        RETURNING languagemasterid INTO template_description_id;

        INSERT INTO public.worktemplate(worktemplatecustomerid,
                                        worktemplatesiteid,
                                        worktemplatenameid,
                                        worktemplateneedstranslation,
                                        worktemplateallowondemand,
                                        worktemplateworkfrequencyid,
                                        worktemplatemodifiedby,
                                        worktemplatelocationtypeid,
                                        worktemplatesoplink,
                                        worktemplatedescriptionid)
        VALUES (tempcustomerid,
                tempsiteid,
                templanguagemasterid,
                FALSE,
                TRUE,
                1, -- this is placeholder for the frequencyid we are about to create
                create_modifiedby,
                tempcustagsitetypeid,
                'https://beta.console.tendrel.io/checklist',
                template_description_id)
        RETURNING worktemplateid,id INTO tempworktemplateid, tempworktemplateuuid;

        RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

        INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                         workfrequencycustomerid,
                                         workfrequencytypeid,
                                         workfrequencyvalue,
                                         workfrequencystartdate,
                                         workfrequencymodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                740,
                1,
                CLOCK_TIMESTAMP(),
                create_modifiedby)
        RETURNING workfrequencyid INTO tempworkfrequencyid;

        RAISE NOTICE 'inserted frequency';

        UPDATE worktemplate w
        SET worktemplateworkfrequencyid = tempworkfrequencyid
        WHERE worktemplateid = tempworktemplateid;

-- add the contraints

        INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                            worktemplateconstraintcustomeruuid,
                                            worktemplateconstrainttemplateid,
                                            worktemplateconstraintconstraintid, -- Location Type in custag
                                            worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                            worktemplateconstraintmodifiedby)
        VALUES (tempcustomerid,
                create_customeruuid,
                tempworktemplateuuid,
                tempcustagsitetypeuuid,
                'd8dfd8de-ffdc-4472-8d38-171351668e9d',
                create_modifiedby);

        RAISE NOTICE 'first constraint';
-- Next template for in progress

        INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                    worktemplatenexttemplatenexttemplateid,
                                                    worktemplatenexttemplatecustomerid,
                                                    worktemplatenexttemplateviastatuschange,
                                                    worktemplatenexttemplateviastatuschangeid,
                                                    worktemplatenexttemplatesiteid,
                                                    worktemplatenexttemplatetypeid,
                                                    worktemplatenexttemplatemodifiedby)
        VALUES (tempworktemplateid,
                tempworktemplateid,
                tempcustomerid,
                TRUE,
                707,
                tempsiteid,
                811,
                create_modifiedby);

-- set tiny tendies types

        INSERT INTO worktemplatetype AS w
        (worktemplatetypeworktemplateuuid,
         worktemplatetypesystaguuid,
         worktemplatetypeworktemplateid,
         worktemplatetypesystagid,
         worktemplatetypecustomerid,
         worktemplatetypecustomeruuid)
        VALUES (tempworktemplateuuid,
                'ad2f2ced-06ca-46ab-8d75-a2c0a97ad33d',
                tempworktemplateid,
                969,
                tempcustomerid,
                create_customeruuid);

        RAISE NOTICE 'inserted template';
        -- Add in workresults here
--"Time At Task"

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresultsiteid,
                                      workresultfortask,
                                      workresultforaudit,
                                      workresulttypeid,
                                      workresultlanguagemasterid,
                                      workresultorder,
                                      workresultisvisible,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                tempsiteid,
                TRUE,
                FALSE,
                737,
                4367,
                0,
                FALSE,
                TRUE,
                create_modifiedby);

        -- Checklist    ************

-- Checklist - Geolocation (using our widget.  May remove this later or not use it at all.)
        -- insert into public.languagemaster
        -- (languagemastercustomerid,
        --  languagemastercustomersiteid,
        --  languagemastersourcelanguagetypeid,
        --  languagemastersource,
        --  languagemastermodifiedby)
        -- values (tempcustomerid,
        --         tempsiteid,
        --         20,
        --         'Checklist - Geolocation',
        --         create_modifiedby)
        -- Returning languagemasterid into templanguagemasterid;

        -- INSERT INTO public.workresult(workresultworktemplateid,
        --                               workresultcustomerid,
        --                               workresulttypeid,
        --                               workresultforaudit,
        --                               workresultstartdate,
        --                               workresultlanguagemasterid,
        --                               workresultsiteid,
        --                               workresultorder,
        --                               workresultiscalculated,
        --                               workresultiseditable,
        --                               workresultisvisible,
        --                               workresultisrequired,
        --                               workresultfortask,
        --                               workresultisprimary,
        --                               workresultmodifiedby)
        -- values (tempworktemplateid,
--             tempcustomerid,
--             890,   -- geolocation type
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- -- Checklist - Number (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - Number',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             701,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- Checklist - Clicker (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'Clicker Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                700,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                1,
                FALSE,
                TRUE,
                TRUE,
                FALSE,
                TRUE,
                FALSE,
                create_modifiedby);

-- Checklist - Boolean (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'True/False Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                754,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                1,
                FALSE,
                TRUE,
                TRUE,
                FALSE,
                TRUE,
                FALSE,
                create_modifiedby);

-- Checklist - Text (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'Long Text Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        --         insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Widgets can have default values, saving you time if they frequently have the same value. You can configure default values in the Tendrel Console.',
--             create_modifiedby)
--     Returning languagemasterid into long_text_default_value_id;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultisprimary,
                                      workresultmodifiedby,
                                      workresultdefaultvalue)
        VALUES (tempworktemplateid,
                tempcustomerid,
                702,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                1,
                FALSE,
                TRUE,
                TRUE,
                FALSE,
                TRUE,
                FALSE,
                create_modifiedby,
                'Widgets can be pre-configured with default values in the Tendrel Console, saving time by automatically applying frequently used result values.');

        -- -- Checklist - Sentiment (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - Sentiment',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             704,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- -- Checklist - String (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - String',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             771,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- -- Checklist - Date (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - Date',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             868,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

--" Primary Location"
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'Location',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultentitytypeid,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                848,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                996,
                FALSE,
                FALSE,
                FALSE,
                FALSE,
                TRUE,
                852,
                TRUE,
                create_modifiedby)
        RETURNING workresultid INTO tempworkresultid;

--"Primary Worker"
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
                'Worker',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultentitytypeid,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                848,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                997,
                FALSE,
                FALSE,
                FALSE,
                FALSE,
                TRUE,
                850,
                TRUE,
                create_modifiedby)
        RETURNING workresultid INTO tempworkresultidforworker;

        -- Add in instances
-- RTLS only has ondemand

        INSERT INTO public.workinstance(workinstancecustomerid,
                                        workinstanceworktemplateid,
                                        workinstancesiteid,
                                        workinstancetypeid,
                                        workinstancestatusid,
                                        workinstancetargetstartdate,
                                        workinstancetimezone,
                                        workinstancerefid, -- put location here to start
                                        workinstancemodifiedby)
        VALUES (tempcustomerid,
                tempworktemplateid,
                tempsiteid,
                811, -- this is the work type for task.
                706, -- this is the status for Open.
                CLOCK_TIMESTAMP(),
                create_timezone,
                tempsiteid,
                create_modifiedby)
        RETURNING workinstanceid INTO tempworkinstanceid;

        UPDATE workinstance
        SET workinstanceoriginatorworkinstanceid = workinstanceid
        WHERE workinstancecustomerid = tempcustomerid
          AND workinstanceoriginatorworkinstanceid ISNULL;

-- Insert for tasks
        INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                              workresultinstancecustomerid,
                                              workresultinstanceworkresultid,
                                              workresultinstancemodifiedby,
                                              workresultinstancevalue)
        VALUES (tempworkinstanceid,
                tempcustomerid,
                tempworkresultid,
                create_modifiedby,
                tempsiteid);

        INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                              workresultinstancecustomerid,
                                              workresultinstanceworkresultid,
                                              workresultinstancemodifiedby,
                                              workresultinstancevalue)
        VALUES (tempworkinstanceid,
                tempcustomerid,
                tempworkresultidforworker,
                create_modifiedby,
                NULL);

        RAISE NOTICE 'inserted work instances';
        -- Cleanup widget and format
-- Number
        UPDATE workresult
        SET workresultwidgetid     = 407,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 701
          AND workresultwidgetid IS NULL;

-- Clicker
        UPDATE workresult
        SET workresultwidgetid     = 406,
            workresulttypeid       = 701,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 700
          AND workresultwidgetid IS NULL;

-- boolean
        UPDATE workresult
        SET workresultwidgetid     = 414,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 754
          AND workresultwidgetid IS NULL;

-- tat
        UPDATE workresult
        SET workresultwidgetid     = 413,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 737
          AND workresultwidgetid IS NULL;

--Text
        UPDATE workresult
        SET workresultwidgetid     = 408,
            workresulttypeid       = 771,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 702
          AND workresultwidgetid IS NULL;

--Sentiment
        UPDATE workresult
        SET workresultwidgetid     = 410,
            workresulttypeid       = 701,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 704
          AND workresultwidgetid IS NULL;

--String
        UPDATE workresult
        SET workresultwidgetid     = 412,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 771
          AND workresultwidgetid IS NULL;

-- entity
        UPDATE workresult
        SET workresultwidgetid     = 415,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 848
          AND workresultwidgetid IS NULL;

-- date
        UPDATE workresult
        SET workresultwidgetid     = 419,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 868
          AND workresultwidgetid IS NULL;

-- Geolocation
        UPDATE workresult
        SET workresultwidgetid     = 463,
            workresulttypeid       = 771,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 890
          AND workresultwidgetid IS NULL;

    END IF;

-- Add in customerconfigs

    SELECT uuid
    INTO Checklist_config_template_uuid
    FROM public.crud_customer_config_templates_list(20)
    WHERE category = 'Applications'
      AND type = 'Checklist';

    -- get uuids
    CALL public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := Checklist_config_template_uuid,
                                            config_value := 'true', modified_by := create_adminuuid,
                                            config_id := Checklist_config_uuid);

    COMMIT;
*/
END;

$procedure$;


REVOKE ALL ON PROCEDURE crud_checklist_create_customer(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_checklist_create_customer(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_checklist_create_customer(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_config_activate(text,text,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_config_activate(IN customer_uuid text, IN config_uuid text, IN modified_by text, OUT activated_config_id text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Check if customer config exists
    PERFORM *
    FROM public.customerconfig
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer configuration does not exist';
    END IF;

    -- Activate customer config
    UPDATE public.customerconfig
    SET customerconfigenddate      = NULL,
        customerconfigmodifiedby   = modified_by,
        customerconfigmodifieddate = clock_timestamp()
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid
    RETURNING customerconfiguuid INTO activated_config_id;
END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_activate(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_activate(text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_activate(text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_config_create(text,text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_config_create(IN customer_uuid text, IN site_uuid text, IN config_template_uuid text, IN config_value text, IN modified_by text, OUT config_id text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    config_template_type_uuid text;
    config_value_type_uuid    text;


BEGIN
    -- Check if customer exists
    PERFORM * FROM public.customer WHERE customeruuid = customer_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    SELECT type_uuid,
           value_type_uuid
    INTO config_template_type_uuid, config_value_type_uuid
    FROM public.crud_customer_config_templates_list(20)
    WHERE uuid = config_template_uuid;

    IF (SELECT EXISTS(SELECT customerconfiguuid
                      FROM public.customerconfig c
                      WHERE customerconfigcustomeruuid = customer_uuid
                        AND customerconfigsiteuuid = site_uuid
                        AND customerconfigtypeuuid = config_template_type_uuid
                        AND customerconfigvaluetypeuuid = config_value_type_uuid)) THEN
        RAISE NOTICE 'This config already exists for this customer!';
    END IF;

        -- Insert new customer config and return the newly generated UUID
        INSERT INTO public.customerconfig (customerconfigcustomeruuid, customerconfigsiteuuid,
                                           customerconfigtypeuuid, customerconfigvaluetypeuuid, customerconfigvalue,
                                           customerconfigmodifiedby)
        VALUES (customer_uuid, site_uuid, config_template_type_uuid, config_value_type_uuid, config_value, modified_by)
        RETURNING customerconfiguuid INTO config_id;
    END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_create(text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_create(text,text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_create(text,text,text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_config_delete(text,text,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_config_delete(IN customer_uuid text, IN config_uuid text, IN modified_by text, OUT deleted_config_id text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Check if customer config exists
    PERFORM *
    FROM public.customerconfig
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer configuration does not exist';
    END IF;

    -- Delete customer config
    UPDATE public.customerconfig
    SET customerconfigenddate      = clock_timestamp(),
        customerconfigmodifiedby   = modified_by,
        customerconfigmodifieddate = clock_timestamp()
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid
    RETURNING customerconfiguuid INTO deleted_config_id;
END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_delete(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_delete(text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_delete(text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_customer_config_list(text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_customer_config_list(customer_uuid_param text, language_id bigint)
 RETURNS TABLE(uuid text, started_at timestamp without time zone, ended_at timestamp without time zone, updated_by_uuid text, type text, type_uuid text, value text, value_type text, value_type_uuid text, category text, category_uuid text, name text, site_uuid text)
 LANGUAGE sql
AS $function$
SELECT customerconfiguuid       as uuid,
       customerconfigstartdate  as started_at,
       customerconfigenddate    as ended_at,
       customerconfigmodifiedby as updated_by_uuid,
       config_type.systagtype   as type,
       customerconfigtypeuuid   as type_uuid,
       customerconfigvalue      as value,
       value_type.systagtype    as value_type,
       value_type.systaguuid    as value_type_uuid,
       category.systagname      as category,
       category.systaguuid      as category_uuid,
       config_type.systagname   as name,
       customerconfigsiteuuid   as site_uuid
FROM public.customerconfig cc
         INNER JOIN public.view_systag config_type
                    ON cc.customerconfigtypeuuid = config_type.systaguuid and
                       config_type.languagetranslationtypeid = language_id
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
         INNER JOIN public.view_systag category
                    ON config_type.systagparentid = category.systagid and
                       category.languagetranslationtypeid = language_id
WHERE customerconfigcustomeruuid = customer_uuid_param
AND customerconfigistemplate = false
ORDER BY category asc, name asc
$function$;


REVOKE ALL ON FUNCTION crud_customer_config_list(text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_list(text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_list(text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_customer_config_templates_list(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_customer_config_templates_list(language_id bigint)
 RETURNS TABLE(uuid text, type_uuid text, type text, value text, value_type text, value_type_uuid text, category text, category_uuid text, name text)
 LANGUAGE sql
AS $function$
SELECT customerconfiguuid     as uuid,
       customerconfigtypeuuid as type_uuid,
       config_type.systagtype as type,
       customerconfigvalue    as value,
       value_type.systagtype  as value_type,
       value_type.systaguuid  as value_type_uuid,
       category.systagname    as category,
       category.systaguuid    as category_uuid,
       config_type.systagname as name
FROM public.customerconfig cc
         INNER JOIN public.view_systag config_type
                    ON cc.customerconfigtypeuuid = config_type.systaguuid and
                       config_type.languagetranslationtypeid = language_id
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
         INNER JOIN public.view_systag category
                    ON config_type.systagparentid = category.systagid and
                       category.languagetranslationtypeid = language_id
WHERE customerconfigsiteuuid is null
  and customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0)
  and customerconfigistemplate = true
ORDER BY category asc, name asc
$function$;


REVOKE ALL ON FUNCTION crud_customer_config_templates_list(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_templates_list(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_templates_list(bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_config_update(text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_config_update(IN customer_uuid text, IN config_uuid text, IN config_value text, IN modified_by text, OUT updated_config_id text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Check if customer config exists
    PERFORM *
    FROM public.customerconfig
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer configuration does not exist';
    END IF;

    -- Update customer config
    UPDATE public.customerconfig
    SET customerconfigvalue        = config_value,
        customerconfigmodifiedby   = modified_by,
        customerconfigmodifieddate = clock_timestamp()
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid
    RETURNING customerconfiguuid INTO updated_config_id;
END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_update(text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_update(text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_update(text,text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_create(IN create_customername text, IN create_sitename text, OUT create_customeruuid text, IN create_customerbillingid text, IN create_customerbillingsystemid text, INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid text, OUT create_adminuuid text, OUT create_siteuuid text, IN create_timezone text, IN create_languagetypeuuids text[], IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
    tempcustomerid                 bigint;
	tempcustomerentityuuid			uuid;
	tempsiteentityuuid				uuid;
	temptestlog text;
	templanguagetype_id uuid[];
	tempcustomerbillingsystemuuid uuid;
	tempadminidentitysystemuuid uuid;
	templadminid bigint;
Begin

/*

call public.crud_customer_create(
	create_customername := 'Test Keller v2',
	create_sitename := 'My Test Site',
	create_customeruuid := null::text,
	create_customerbillingid := 'fake-billing-id',
	create_customerbillingsystemid := null::text,
	create_adminfirstname := 'Mark',
	create_adminlastname := 'Keller',
	create_adminemailaddress := 'keller@tendrel.io',
	create_adminphonenumber := null::text,
	create_adminidentityid := 'user_2j7hB374BA7oaodEeJoHGFmz7wB',
	create_adminidentitysystemuuid := '0c1e3a50-ed4c-4469-95bd-e091104ae9d5',
	create_adminuuid := null::text,
	create_siteuuid := null::text,
	create_timezone := 'America/Los_Angeles',
	create_languagetypeuuids := Array['7ebd10ee-5018-4e11-9525-80ab5c6aebee'],
	create_modifiedby := 337)

*/

---------------------------------------------
--need to convert the "languagetypeuuids and create_customerbillingsystemid from text to uuid"

templanguagetype_id = Array(select systagentityuuid 
							from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
							where systaguuid = ANY (create_languagetypeuuids));

tempcustomerbillingsystemuuid = (select systagentityuuid 
								from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
								where systaguuid = create_customerbillingsystemid);	

tempadminidentitysystemuuid = (select systagentityuuid 
								from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
								where systaguuid = create_adminidentitysystemuuid);	

call entity.crud_customer_create_tendrel(
	create_customername := create_customername,
	create_customeruuid := create_customeruuid,
	create_customerentityuuid := tempcustomerentityuuid,
	create_siteuuid := create_siteuuid,
	create_siteentityuuid := tempsiteentityuuid,
	create_customerparentuuid := null::uuid,
	create_customerowner := null::uuid,
	create_customerbillingid := create_customerbillingid,
	create_customerbillingsystemid := tempcustomerbillingsystemuuid,
	create_customerdeleted := null::boolean,
	create_customerdraft := null::boolean,
	create_adminfirstname := create_adminfirstname,
	create_adminlastname := create_adminlastname,
	create_adminemailaddress := create_adminemailaddress,
	create_adminphonenumber := create_adminphonenumber,
	create_adminidentityid := create_adminidentityid,
	create_adminidentitysystemuuid := tempadminidentitysystemuuid,
	create_adminid := templadminid,
	create_adminuuid := create_adminuuid,
	create_languagetypeuuids := templanguagetype_id,
	create_timezone := create_timezone,
	create_modifiedby := create_modifiedby,
	testlog := temptestlog);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_delete(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_delete(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

-- set the customer as modified

update customer
set customerenddate = clock_timestamp() - interval '1 day',
	customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_delete(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_delete(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_delete(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_metering_query(integer,integer,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_metering_query(IN billing_month integer, IN billing_year integer, IN modified_by_workerinstance_uuid text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	customer_record record;
BEGIN
	
insert into customerbillingrecord(
	customerbillingrecordcustomerid, 
	customerbillingrecordcreateddate,			 
	customerbillingrecordmodifieddate, 
	customerbillingrecordmodifiedby,
    customerbillingrecordstatusuuid, 
	customerbillingrecordvalue, 
	customerbillingrecordbillingmonth,
	customerbillingrecordbillingyear, 									 
	customerbillingrecordbillingsystemuuid, 
	customerbillingrecordbillingid,
	customerbillingrecordcustomertypeuuid,
	customerbillingrecordcustomertypename,
	customerbillingrecordcustomeruuid) 
select 
	customerid,
	now(),
	now(),
	modified_by_workerinstance_uuid,
    'eb919f8c-ac25-4bbc-bec9-61feb7d3d073'::text,
	count(*) as workercount, 
	billinghistorymonth,
	billinghistoryyear,
	billinghistorycustomerexternalsystemuuid,
	billinghistorycustomerexternalid,
	customertypeuuid,
	systagtype,
	billinghistorycustomeruuid
from ( 
	select 
		billinghistorystatustype,
		billinghistorymonth, 
		billinghistoryyear,
		billinghistoryworkerinstanceid,
		billinghistorycustomeruuid,
		billinghistorycustomerexternalid,
		billinghistorycustomerexternalsystemuuid,
		customerid,
		customertypeuuid,
		systagtype
	from datawarehouse.billinghistory
		inner join customer
			on customeruuid = billinghistorycustomeruuid
		inner join systag
			on customertypeuuid = systaguuid
	where
		billinghistorymonth=billing_month
		AND billinghistoryyear=billing_year
		AND billinghistorystatusuuid='64c1e074-ea89-4b5a-88a8-40522b57e400'
		AND billinghistorycustomerbillingrecorduuid is null
	group by
		billinghistorystatustype,
		billinghistorymonth, 
		billinghistoryyear,
		billinghistoryworkerinstanceid,
		billinghistorycustomeruuid,
		billinghistorycustomerexternalid,
		billinghistorycustomerexternalsystemuuid,
		customerid,
		customertypeuuid,
		systagtype
	) 	as uniqueworkerbillingrecords
where 
	billinghistorycustomerexternalsystemuuid IS NOT null 
	AND billinghistorycustomerexternalid IS NOT null
group by 
	billinghistorycustomeruuid,
	billinghistorycustomerexternalid,
	billinghistorycustomerexternalsystemuuid,
	billinghistorymonth,
	billinghistoryyear,
	customertypeuuid,
	systagtype,
	billinghistorycustomeruuid,
	customerid;
	
	
update datawarehouse.billinghistory
set 
	billinghistorycustomerbillingrecorduuid = customerbillingrecorduuid,
	billinghistorymodifieddate = now()
	--billinghistorymodifiedby = modified_by_workerinstance_uuid
from customerbillingrecord
where
	billinghistorymonth=billing_month
	and billinghistoryyear=billing_year
	and billinghistorystatusuuid='64c1e074-ea89-4b5a-88a8-40522b57e400' -- is charge
	and billinghistorycustomerbillingrecorduuid is null
	and billinghistorycustomeruuid = customerbillingrecordcustomeruuid
	and customerbillingrecordbillingmonth=billing_month
	and customerbillingrecordbillingyear=billing_year;

END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_metering_query(integer,integer,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_metering_query(integer,integer,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_metering_query(integer,integer,text) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_customer_read(text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_customer_read(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text)
 RETURNS TABLE(customerid bigint, customernamelanguagemasterid bigint, customername text, customerlanguagetypeid bigint, customerlanguagetypeuuid text, customerlanguagetypename text, customerstartdate timestamp with time zone, customerenddate timestamp with time zone, customerexternalid text, customerexternalsystemid bigint, customerexternalsystemuuid text, customerexternalsystemname text, customercreateddate timestamp with time zone, customermodifieddate timestamp with time zone, customermodifiedby bigint)
 LANGUAGE sql
AS $function$

-- Example to call function

SELECT 
	customerid, 
	customernamelanguagemasterid, 
	customername, 
	customerlanguagetypeid,
	customerlanguagetypeuuid,
	lt.systagtype as customerlanguagetypename,
	customerstartdate, 
	customerenddate, 
	customerexternalid, 
	customerexternalsystemid,
	customerexternalsystemuuid,
	sn.systagtype as  customerexternalsystemname, 
	customercreateddate, 
	customermodifieddate, 
	customermodifiedby
FROM public.customer c
	inner join systag lt
		on customerlanguagetypeuuid = lt.systaguuid
	left join systag sn
		on customerexternalsystemuuid = sn.systaguuid
where (read_customeruuid = customeruuid 
		or (read_customerexternalid = customerexternalid
		and read_customerexternalsystemuuid = customerexternalsystemuuid));

$function$;


REVOKE ALL ON FUNCTION crud_customer_read(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_read(text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_read(text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_restart(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_restart(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

update customer
set customerenddate = null,
	customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_restart(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_restart(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_restart(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_customer_update(text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_update(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_customername text, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	templanguagetypeid bigint;
	tempcustomerexternalsystemid bigint;
Begin

-- We only allow the name and languagetype to change
-- we won't update external systems with this change.  Possibly a future enhancement.

-- If the name changed then we update the name in the languagemaster and in the customer tables

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = update_languagetypeuuid);

tempcustomerexternalsystemid = (select systagid 
								  from systag
								  where systaguuid = update_customerexternalsystemuuid);

update_customeruuid = (select customeruuid 
								  from customer
								  where (update_customeruuid = customeruuid 
									or (update_customerexternalid = customerexternalid
									and update_customerexternalsystemuuid = customerexternalsystemuuid)));

if (update_customername notNull and update_customername <> '')
	then 
		update languagemaster
		set languagemastersource = update_customername,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifiedby = update_modifiedbyid,
			languagemastermodifieddate = clock_timestamp()
		from customer
		where (update_customeruuid = customeruuid 
				or (update_customerexternalid = customerexternalid
				and update_customerexternalsystemuuid = customerexternalsystemuuid))
			and customernamelanguagemasterid = languagemasterid
			and customername <> update_customername;
		
		update customer
		set customername = update_customername
		where (update_customeruuid = customeruuid 
				or (update_customerexternalid = customerexternalid
				and update_customerexternalsystemuuid = customerexternalsystemuuid))
			and customername <> update_customername;
end if;

-- Set language type id for the customer
-- We could harden this to check to see if the languagetype id is valid 
-- For now I will assume it is ok

update customer
set customerlanguagetypeid = templanguagetypeid,
	customerlanguagetypeuuid = update_languagetypeuuid	
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid))
	and update_languagetypeuuid notNull
	and customerlanguagetypeuuid <> update_languagetypeuuid;

-- set the customer as modified

update customer
set customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_update(text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_update(text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_update(text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_language_list(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_language_list(language_id bigint)
 RETURNS TABLE(uuid text, id bigint, name text, code text)
 LANGUAGE plpgsql
AS $function$

Declare
    templanguageid bigint;
BEGIN

    if language_id isNull
    then
        templanguageid = 20;
    else
        templanguageid = language_id;
    end if;

    RETURN QUERY SELECT language.systaguuid as uuid,
                        language.systagid   as id,
                        language.systagname as name,
                        language.systagtype as code
                 FROM public.view_systag language
                 where systagparentid =
                       (select systagid from systag tag where tag.systagparentid = 1 and tag.systagtype = 'Language')
                   and languagetranslationtypeid = templanguageid
                 order by systagname;

End;

$function$;


REVOKE ALL ON FUNCTION crud_language_list(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_language_list(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_language_list(bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_location_create(IN create_customeruuid text, IN create_customerexternalid text, IN create_customerexternalsystemuuid text, IN create_siteid bigint, IN create_locationparentid bigint, IN create_locationcornerstoneid bigint, IN create_locationiscornerstone boolean, IN create_locationcornerstoneorder bigint, IN create_locationname text, IN create_locationlookupname text, IN create_locationscanid text, IN create_locationtypeid bigint, IN create_locationtype text, IN create_locationexternalid text, IN create_locationexternalsystemuuid text, IN create_languagetypeuuid text, IN create_modifiedbyid bigint, INOUT templocationid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempcustagid bigint;
	tempcustaguuid text;
	tempsiteid bigint;
	templocationtimezone text;
	templanguagetypeid bigint;
	templocationexternalsystemid bigint;
	templocationcornerstoneid bigint;
	templocationiscornerstone boolean;
	templocationcornerstoneorder bigint;
	templocationmodifieddate  timestamp with time zone;

Begin

-- We could harden this by checking for valid data at the beginning of this call.  Will do this as phase 2.  
	-- Must have a valid customerid or customerexternalid
	-- Site Name and Site type can not be null or ''
	-- languagetype id must be a valid languagetypeid
	-- locationtimezone must be a legit timezone
	-- modified by id gets defaulted if it is not passed in (Maybe validate this)
	-- Could check all this and return null if any of these fail

-- Set the customerid if it is null

tempcustomeruuid = (select customeruuid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

-- Setup the Custag for the locationtype
	
-- insert the custag 

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = create_languagetypeuuid);

if create_locationtypeid isNull
	then
		tempcustaguuid = (select custaguuid from custag 
					where custagtype = create_locationtype
						and custagcustomeruuid = tempcustomeruuid);
		tempcustagid = (select custagid from custag 
					where custagtype = create_locationtype
						and custagcustomeruuid = tempcustomeruuid);
	else 
		tempcustaguuid = (select custaguuid from custag 
					where custagtype = create_locationtype
						and custagcustomerid = create_locationtypeid);
		tempcustagid = create_locationtypeid;
end if;

templocationexternalsystemid = (select systagid from systag
								where systaguuid = create_locationexternalsystemuuid);

if tempcustaguuid isNull
	then 
		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid, 
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				tempcustomeruuid,
				713,  -- Systagid for Location Category
				(select systaguuid from systag where systagid = 713),
				4367, -- dummy variable
				create_locationtype,
				clock_timestamp(),
				create_modifiedbyid)
				Returning custaguuid, custagid into tempcustaguuid,tempcustagid;

		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastercustomersiteid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid, 	
			create_siteid,
			create_locationtype,
			create_modifiedbyid)
		Returning languagemasterid into templanguagemasterid;

		-- Set the CustTag table to reference the correct translations

		update public.custag
		set custagnameid = templanguagemasterid
		where custagid = tempcustagid    
			and custagcustomerid = tempcustomerid;

end if;

-- insert the custag into languagemaster

-- see if the location already exists

templocationid = (select locationid
				 from view_location
				 where locationcustomerid = tempcustomerid
					and locationcategoryid = tempcustagid
					and locationistop = false
					and locationsiteid = create_siteid
					and locationfullname = create_locationname
					and languagetranslationtypeid = templanguagetypeid);

templocationtimezone = (select locationtimezone
						from location
						where locationid = create_siteid);

if templocationid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastercustomersiteid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			templanguagetypeid,
			create_siteid,
			create_locationname,
			create_modifiedbyid)
		returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationsiteid,
			locationparentid,
			locationiscornerstone,
			locationlookupname,
			locationscanid,
			locationistop,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationexternalid,
			locationexternalsystemid,			
			locationmodifiedby)
		values(	
			tempcustomerid,
			create_siteid,
			case
				when create_locationparentid isNull
					then create_siteid
				else
					create_locationparentid
			end,
			false,
			create_locationname,
			create_locationscanid,			
			FALSE,
			tempcustagid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   -- https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
			create_locationexternalid,	
			templocationexternalsystemid,
			create_modifiedbyid)
		returning locationid into  templocationid;
end if;

if create_locationiscornerstone = true or create_locationcornerstoneid isnull
	then
		templocationcornerstoneid = templocationid;
		templocationiscornerstone = true;
		templocationcornerstoneorder = 1;
		templocationmodifieddate = clock_timestamp();
	else
		templocationcornerstoneid = create_locationcornerstoneid;
		templocationiscornerstone = false;
		templocationcornerstoneorder = create_locationcornerstoneorder;
		templocationmodifieddate = clock_timestamp();
End if;
		

update location
	set locationcornerstoneid = templocationcornerstoneid,
		locationiscornerstone = templocationiscornerstone,
		locationcornerstoneorder = templocationcornerstoneorder,
		locationmodifieddate = clock_timestamp()
	where locationid = templocationid and locationcustomerid = tempcustomerid;

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_create(text,text,text,bigint,bigint,bigint,boolean,bigint,text,text,text,bigint,text,text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_location_delete(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_location_delete(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_locationid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
	Future:  Add in a site check
	Future:  Cascade changes

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_siteid
										and locationcustomerid = tempcustomerid
										and locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Location does not exist';
    END IF;

	
update location
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_locationid 
	and locationistop = false
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_delete(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_delete(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_delete(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_location_read(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_location_read(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_locationid bigint, read_languagetypeuuid text)
 RETURNS TABLE(locationid bigint, locationcustomerid bigint, locationcategoryid bigint, locationcategory text, locationlanguagetypeid bigint, locationlanguagetypename text, locationnameid bigint, locationfullname text, locationscanid text, locationlookupname text, locationtimezone text, locationsiteid bigint, locationsitename text, locationparentid bigint, locationparentname text, locationiscornerstone boolean, locationcornerstoneid bigint, locationcornerstonename text, locationcornerstoneorder bigint, locationstartdate timestamp with time zone, locationenddate timestamp with time zone, locationexternalsystemid bigint, locationexternalid text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	templanguagetypeid bigint;

Begin
-- does not work for sites

tempcustomerid = (select customerid 
					from customer 
					where (read_customeruuid = customeruuid 
						or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid))); 

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = read_languagetypeuuid);

RETURN QUERY SELECT 
	loc.locationid, 
	loc.locationcustomerid, 
	cat.custagid as locationcategoryid,
	cat.custagtype as locationcategory,
	lan.systagid as locationlanguagetypeid,
	lan.systagtype as locationlanguagetypename, 
	loc.locationnameid, 
	loc.locationfullname,  
	loc.locationscanid,
	loc.locationlookupname,
	loc.locationtimezone,
	loc.locationsiteid,	
	site.locationfullname as locationsitename,
	loc.locationparentid,	
	parent.locationfullname as locationparentname,	
	loc.locationiscornerstone, 
	loc.locationcornerstoneid,
	corner.locationfullname as locationcornerstonename,  -- join this in
	loc.locationcornerstoneorder, 
	loc.locationstartdate, 
	loc.locationenddate, 
	loc.locationexternalsystemid, 
	loc.locationexternalid
FROM public.view_location loc
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join view_location site
		on site.locationid = loc.locationsiteid
			and site.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join view_location parent
		on parent.locationid = loc.locationparentid
			and parent.languagetranslationtypeid = loc.languagetranslationtypeid
	left join view_location corner
		on corner.locationid = loc.locationcornerstoneid
			and corner.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join custag cat
		on cat.custagid = loc.locationcategoryid
where loc.locationid = read_locationid
	and loc.locationistop = false
	and loc.locationcustomerid = tempcustomerid
	and loc.languagetranslationtypeid = templanguagetypeid;

End;

$function$;


REVOKE ALL ON FUNCTION crud_location_read(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_location_read(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_location_read(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_location_restart(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_location_restart(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_locationid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

	tempcustomerid bigint;
	
Begin

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));
	
update location
set locationenddate = null,
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_locationid 
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_restart(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_restart(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_restart(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_location_update(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_siteid bigint, IN update_parentid bigint, INOUT update_locationid bigint, IN update_locationexternalid text, IN update_locationexternalsystemuuid text, IN update_locationfullname text, IN update_locationlookupname text, IN update_locationscanid text, IN update_locationiscornerstone boolean, IN update_locationcornerstoneid bigint, IN update_locationcornerstoneorder bigint, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsiteid bigint;
	tempparentid bigint;
	templocationid bigint;	
	updatelocationexternalid text;
	updatelocationexternalsystemid bigint;
	templocationfullname text;
	updatelocationlookupname text;	
	updatelocationscanid text;	
	updatelocationiscornerstone boolean;		
	updatelocationcornerstoneid bigint;
	updatelocationcornerstoneorder bigint;
	updatelocationtimezone text;	
	templanguagetypeid bigint;
	templocationlanguagetypeid bigint;
	updatelocationmodifieddate  timestamp with time zone;
Begin

-- We only allow the name,lookupname, scanid, and languagetype to change
-- we won't update external systems with this change.  Possibly a future enhancement.

if update_languagetypeuuid isNull
	then 
		templanguagetypeid =  20;
	else 
		templanguagetypeid = (select systagid from systag where systaguuid = update_languagetypeuuid);
end if;

-- update customer id

tempcustomeruuid = (select customeruuid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

CREATE TEMP TABLE templocation AS
select 
	locationid as templocationid,
	locationsiteid as  tempsiteid,
	locationparentid as  tempparentid,	
   	locationnameid as templanguagemasterid,
	locationexternalid as templocationexternalid,
	locationexternalsystemid as templocationexternalsystemid,
	locationfullname as templocationfullname,
	locationlookupname as templocationlookupname,
	locationscanid as templocationscanid,
	locationiscornerstone as templocationiscornerstone,	
	locationcornerstoneid as templocationcornerstoneid,
	locationcornerstoneorder as templocationcornerstoneorder,
	locationtimezone as templocationtimezone	
from view_location
where languagetranslationtypeid = templanguagetypeid
	and locationcustomerid = tempcustomerid
	and locationid = update_locationid;

-- If the name changed then we update the name in the languagemaster and in the customer tables

update languagemaster
set languagemastersource = update_locationfullname,
	languagemastersourcelanguagetypeid = templanguagetypeid,
	languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
	languagemastermodifiedby = update_modifiedbyid,
	languagemastermodifieddate = clock_timestamp()
from location
where locationid = update_locationid
	and locationnameid = languagemasterid;

if update_locationexternalid isNull  
	then
		updatelocationexternalid = (select templocationexternalid from templocation);
	else
		updatelocationexternalid = update_locationexternalid;
end if;

if update_locationexternalsystemuuid isNull  
	then
		updatelocationexternalsystemid = (select templocationexternalsystemid from templocation);
	else
		updatelocationexternalsystemid = update_locationexternalid;
end if;

if update_locationlookupname isNull 
	then
		updatelocationlookupname = (select templocationlookupname from templocation);
	else	
		updatelocationlookupname = update_locationlookupname;
end if;

if update_locationscanid isNull 
	then
		updatelocationscanid = (select templocationscanid from templocation); 
	Else
		updatelocationscanid = update_locationscanid;
end if;

if update_locationiscornerstone = true or update_locationcornerstoneid isnull
	then
		updatelocationcornerstoneid = update_locationid;
		updatelocationiscornerstone = true;
		updatelocationcornerstoneorder = 1;
		updatelocationmodifieddate = clock_timestamp();
	else
		updatelocationcornerstoneid = create_locationcornerstoneid;
		updatelocationiscornerstone = false;
		updatelocationcornerstoneorder = create_locationcornerstoneorder;
		updatelocationmodifieddate = clock_timestamp();
End if;

update location
	set locationexternalid = updatelocationexternalid,
	locationexternalsystemid = updatelocationexternalsystemid,
	locationlookupname = updatelocationlookupname,
	locationscanid = updatelocationscanid,
	locationiscornerstone = updatelocationiscornerstone,
	locationcornerstoneid = updatelocationcornerstoneid,
	locationcornerstoneorder = updatelocationcornerstoneorder,
	locationmodifieddate = updatelocationmodifieddate,
	locationmodifiedby = update_modifiedbyid
where locationid = update_locationid
	and locationcustomerid = tempcustomerid;

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_update(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_rtls_create_customer(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_rtls_create_customer(IN create_customeruuid text, IN create_siteuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Customer temp values
    tempcustomerid                 bigint := (select customerid from customer where customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp valules
    tempcustagsitetypeid           bigint;
    tempsitename                   text := (select locationlookupname from view_location where locationuuid = create_siteuuid AND languagetranslationtypeid=20);
    tempcustagsitetypeuuid         text := (select custaguuid from custag where custagid =
                                            (select locationcategoryid
                                             from location
                                             where locationuuid=create_siteuuid));
    tempsiteid                     bigint := (select locationid from location where locationuuid = create_siteuuid);
    tempsiteuuid                   text;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
-- RTLS
    RTLS_config_template_uuid text;
    RTLS_config_uuid          text;

Begin
/*
    RAISE NOTICE 'Start of procedure';

-- Add in worktemplates for the site id and location types
-- Add in RTLS template type
IF (SELECT EXISTS(select id from view_worktemplate
		where worktemplatename = 'RTLS'
		and worktemplatecustomerid = tempcustomerid)) THEN
    RAISE NOTICE 'RTLS template exists, skipping.';
ELSE
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid,
                                    worktemplatereapinprogworkmillis)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            FALSE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid,
            -- expiration of 7 days
            604800000)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            748, -- one time frequency
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            create_modifiedby);

    RAISE NOTICE 'first constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            (select systaguuid from systag where systagtype='RTLS' and systagparentid = (select systagid from systag where systagtype='Template Type')),
            tempworktemplateid,
            968,
            tempcustomerid,
            create_customeruuid);

    RAISE NOTICE 'inserted template';
    -- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby);

-- RTLS    ************
-- RTLS - Geolocation (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Geolocation',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             890,   -- geolocation type
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             99,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- RTLS - Accuracy
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Accuracy',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Altitude
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Altitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Altitude Accuracy
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Altitude Accuracy',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Heading (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Heading',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Latitude (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Latitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Longitude (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Longitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Speed (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Speed',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            7,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Online Status (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Online Status',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby,
                                  workresulttranslate)
    values (tempworktemplateid,
            tempcustomerid,
            771,   -- Really this is a drop down and probably a pointer to possible statuses.
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            8,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby,
            FALSE);

--" Primary Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            create_modifiedby)
    Returning workresultid into tempworkresultid;

--"Primary Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            create_modifiedby)
    returning workresultid into tempworkresultidforworker;

-- Cleanup widget and format
-- Number
    update workresult
    set workresultwidgetid     = 407,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 701
      and workresultwidgetid is null;

-- Clicker
    update workresult
    set workresultwidgetid     = 406,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 700
      and workresultwidgetid is null;

-- boolean
    update workresult
    set workresultwidgetid     = 414,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 754
      and workresultwidgetid is null;

-- tat
    update workresult
    set workresultwidgetid     = 413,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 737
      and workresultwidgetid is null;

--Text
    update workresult
    set workresultwidgetid     = 408,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 702
      and workresultwidgetid is null;

--Sentiment
    update workresult
    set workresultwidgetid     = 410,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 704
      and workresultwidgetid is null;

--String
    update workresult
    set workresultwidgetid     = 412,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 771
      and workresultwidgetid is null;

-- entity
    update workresult
    set workresultwidgetid     = 415,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 848
      and workresultwidgetid is null;

-- date
    update workresult
    set workresultwidgetid     = 419,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 868
      and workresultwidgetid is null;

-- Geolocation
--    update workresult
--    set workresultwidgetid     = 463,
--        workresulttypeid       = 771,
--        workresultmodifieddate = clock_timestamp()
--    where workresulttypeid = 890
--      and workresultwidgetid is null;

-- Add in customerconfigs

    select uuid
    into RTLS_config_template_uuid
    from public.crud_customer_config_templates_list(20)
    where category = 'Applications'
      and type = 'RTLS';

    -- get uuids
    call public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := RTLS_config_template_uuid,
                                            config_value := 'true', modified_by := null,
                                            config_id := RTLS_config_uuid);

END IF;

-- Add in worktemplates for the site id and location types
-- Check In/Out will be of the Activity WorkType
-- Check In/Out will be On Demand

IF (SELECT EXISTS(select id from view_worktemplate
		where worktemplatename = 'RTLS - Check In/Out'
		and worktemplatecustomerid = tempcustomerid)) THEN
    RAISE NOTICE 'RTLS Check In/Out template exists, skipping.';
ELSE
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Check In/Out',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',  -- this is 'Location'
            create_modifiedby);

    RAISE NOTICE 'first constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'systag_0da3103c-adc6-4ec2-ac8d-7966a03ad9f6',  -- Activity
            tempworktemplateid,
            968,
            tempcustomerid,
            create_customeruuid);

    RAISE NOTICE 'inserted template';

-- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby,
			413);

-- Primary Location

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            create_modifiedby,
			415)
    Returning workresultid into tempworkresultid;

--"Primary Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            create_modifiedby,
			415)
    returning workresultid into tempworkresultidforworker;

-- Add in ondemand instances

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            create_timezone,
            tempsiteid,
            create_modifiedby)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert result instances
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue,
                                          workresultinstancetimezone)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid,
            create_timezone);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue,
                                          workresultinstancetimezone)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null,
            create_timezone);

    RAISE NOTICE 'inserted work instances';
END IF;

commit;
*/
End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_rtls_create_customer(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_rtls_create_customer(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_rtls_create_customer(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_rtls_create_customer_test(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_rtls_create_customer_test(IN create_customeruuid text, IN create_siteuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Customer temp values
    tempcustomerid                 bigint := (select customerid from customer where customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp valules
    tempcustagsitetypeid           bigint;
    tempsitename                   text := (select locationlookupname from view_location where locationuuid = create_siteuuid AND languagetranslationtypeid=20);
    tempcustagsitetypeuuid         text := (select custaguuid from custag where custagid =
                                            (select locationcategoryid
                                             from location
                                             where locationuuid=create_siteuuid));
    tempsiteid                     bigint := (select locationid from location where locationuuid = create_siteuuid);
    tempsiteuuid                   text;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
-- RTLS
    RTLS_config_template_uuid text;
    RTLS_config_uuid          text;

Begin
/*
    RAISE NOTICE 'Start of procedure';

-- Add in worktemplates for the site id and location types
-- Add in RTLS template type
IF (SELECT EXISTS(select id from view_worktemplate
		where worktemplatename = 'RTLS'
		and worktemplatecustomerid = tempcustomerid)) THEN
    RAISE NOTICE 'RTLS template exists, skipping.';
ELSE
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid,
                                    worktemplatereapinprogworkmillis)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            FALSE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid,
            -- expiration of 7 days
            604800000)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            748, -- one time frequency
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            create_modifiedby);

    RAISE NOTICE 'first constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            (select systaguuid from systag where systagtype='RTLS' and systagparentid = (select systagid from systag where systagtype='Template Type')),
            tempworktemplateid,
            968,
            tempcustomerid,
            create_customeruuid);

    RAISE NOTICE 'inserted template';
    -- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby);

-- RTLS    ************
-- RTLS - Geolocation (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Geolocation',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             890,   -- geolocation type
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             99,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- RTLS - Accuracy
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Accuracy',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Altitude
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Altitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Altitude Accuracy
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Altitude Accuracy',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Heading (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Heading',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Latitude (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Latitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Longitude (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Longitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Speed (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Speed',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            7,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Online Status (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Online Status',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultisprimary,
                                  workresultmodifiedby,
                                  workresulttranslate)
    values (tempworktemplateid,
            tempcustomerid,
            771,   -- Really this is a drop down and probably a pointer to possible statuses.
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            8,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby,
            FALSE);

--" Primary Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            create_modifiedby)
    Returning workresultid into tempworkresultid;

--"Primary Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            create_modifiedby)
    returning workresultid into tempworkresultidforworker;

-- Cleanup widget and format
-- Number
    update workresult
    set workresultwidgetid     = 407,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 701
      and workresultwidgetid is null;

-- Clicker
    update workresult
    set workresultwidgetid     = 406,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 700
      and workresultwidgetid is null;

-- boolean
    update workresult
    set workresultwidgetid     = 414,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 754
      and workresultwidgetid is null;

-- tat
    update workresult
    set workresultwidgetid     = 413,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 737
      and workresultwidgetid is null;

--Text
    update workresult
    set workresultwidgetid     = 408,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 702
      and workresultwidgetid is null;

--Sentiment
    update workresult
    set workresultwidgetid     = 410,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 704
      and workresultwidgetid is null;

--String
    update workresult
    set workresultwidgetid     = 412,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 771
      and workresultwidgetid is null;

-- entity
    update workresult
    set workresultwidgetid     = 415,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 848
      and workresultwidgetid is null;

-- date
    update workresult
    set workresultwidgetid     = 419,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 868
      and workresultwidgetid is null;

-- Geolocation
--    update workresult
--    set workresultwidgetid     = 463,
--        workresulttypeid       = 771,
--        workresultmodifieddate = clock_timestamp()
--    where workresulttypeid = 890
--      and workresultwidgetid is null;

-- Add in customerconfigs

    select uuid
    into RTLS_config_template_uuid
    from public.crud_customer_config_templates_list(20)
    where category = 'Applications'
      and type = 'RTLS';

    -- get uuids
    call public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := RTLS_config_template_uuid,
                                            config_value := 'true', modified_by := null,
                                            config_id := RTLS_config_uuid);

END IF;

-- Add in worktemplates for the site id and location types
-- Check In/Out will be of the Activity WorkType
-- Check In/Out will be On Demand

IF (SELECT EXISTS(select id from view_worktemplate
		where worktemplatename = 'RTLS - Check In/Out'
		and worktemplatecustomerid = tempcustomerid)) THEN
    RAISE NOTICE 'RTLS Check In/Out template exists, skipping.';
ELSE
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Check In/Out',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',  -- this is 'Location'
            create_modifiedby);

    RAISE NOTICE 'first constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'systag_0da3103c-adc6-4ec2-ac8d-7966a03ad9f6',  -- Activity
            tempworktemplateid,
            968,
            tempcustomerid,
            create_customeruuid);

    RAISE NOTICE 'inserted template';

-- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby,
			413);

-- Primary Location

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            create_modifiedby,
			415)
    Returning workresultid into tempworkresultid;

--"Primary Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            create_modifiedby,
			415)
    returning workresultid into tempworkresultidforworker;

-- Add in ondemand instances

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            create_timezone,
            tempsiteid,
            create_modifiedby)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert result instances
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue,
                                          workresultinstancetimezone)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid,
            create_timezone);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue,
                                          workresultinstancetimezone)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null,
            create_timezone);

    RAISE NOTICE 'inserted work instances';
END IF;

commit;
*/
End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_site_create(IN create_customeruuid text, IN create_customerexternalid text, IN create_customerexternalsystemuuid text, IN create_sitename text, IN create_sitetype text, IN create_siteexternaluuid text, IN create_siteexternalsystemuuid text, IN create_locationtimezone text, IN create_languagetypeuuid text, IN create_modifiedbyid bigint, INOUT tempsiteid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempcustagid bigint;
	tempcustaguuid text;
	templocationtimezone text;
	templanguagetypeid bigint;
	tempsiteexternalsystemid bigint;
Begin

-- We could harden this by checking for valid data at the beginning of this call.  Will do this as phase 2.  
	-- Must have a valid customerid or customerexternalid
	-- Site Name and Site type can not be null or ''
	-- languagetype id must be a valid languagetypeid
	-- locationtimezone must be a legit timezone
	-- modified by id gets defaulted if it is not passed in (Maybe validate this)
	-- Could check all this and return null if any of these fail

-- You have to create a customer with a dummy languagemasterid

-- Set the customerid if it is null

tempcustomeruuid = (select customeruuid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

-- insert the custag 

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = create_languagetypeuuid);

tempcustaguuid = (select custaguuid from custag 
					where custagtype = create_sitetype
						and custagcustomeruuid = tempcustomeruuid);

tempcustagid = (select custagid from custag 
					where custagtype = create_sitetype
						and custagcustomeruuid = tempcustomeruuid);

tempsiteexternalsystemid = (select systagid from systag
					where systaguuid = create_siteexternalsystemuuid);

if tempcustaguuid isNull
	then 
		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid, 
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				tempcustomeruuid,
				713,  -- Systagid for Location Category	
				(select systaguuid from systag where systagid = 713),
				4367, -- dummy variable
				create_sitetype,
				now(),
				create_modifiedbyid)
				Returning custaguuid, custagid into tempcustaguuid,tempcustagid;
				
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid, 	
			create_sitetype,
			create_modifiedbyid)
		Returning languagemasterid into templanguagemasterid;

		-- Set the CustTag table to reference the correct translations

		update public.custag
		set custagnameid= templanguagemasterid
		where custaguuid = tempcustaguuid    
			and custagcustomeruuid = tempcustomeruuid;				
				
end if;

-- see if the site exists already

tempsiteid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagid
			 	and locationistop = true
			 	and locationfullname = create_sitename
			 	and languagetranslationtypeid = templanguagetypeid);

if create_locationtimezone isNull
	then 
		templocationtimezone = 'UTC';
	Else 
		templocationtimezone = create_locationtimezone;
End if;

if tempsiteid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			templanguagetypeid,
			create_sitename,
			create_modifiedbyid)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationlookupname,
			locationistop,
			locationiscornerstone,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationexternalid,
			locationexternalsystemid,			
			locationmodifiedby)
		values(	
			tempcustomerid,
			create_sitename,
			TRUE,
			FALSE,
			FALSE,
			tempcustagid,
			now(),  --normally timestamp is now()
			templanguagemasterid,
			templocationtimezone,   -- https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
			create_siteexternaluuid,	
			tempsiteexternalsystemid,
			create_modifiedbyid)
		Returning locationid into tempsiteid;

		update location 
		set locationsiteid = locationid,
			locationparentid = locationid
		where locationid = tempsiteid;
	end if;

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_site_delete(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_site_delete(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	
update location
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_siteid 
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_delete(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_delete(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_delete(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_site_read(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_site_read(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_siteid bigint, read_languagetypeuuid text)
 RETURNS TABLE(locationid bigint, locationcustomerid bigint, locationcategoryid bigint, locationcategory text, locationlanguagetypeid bigint, locationlanguagetypename text, locationnameid bigint, locationfullname text, locationscanid text, locationlookupname text, locationtimezone text, locationsiteid bigint, locationsitename text, locationparentid bigint, locationparentname text, locationiscornerstone boolean, locationcornerstoneid bigint, locationcornerstonename text, locationcornerstoneorder bigint, locationstartdate timestamp with time zone, locationenddate timestamp with time zone, locationexternalsystemid bigint, locationexternalid text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	tempsiteid bigint;
	templanguagetypeid bigint;
	templocationexternalsystemid bigint;

Begin
-- only works for sites

tempcustomerid = (select customerid 
					from customer 
					where (read_customeruuid = customeruuid 
						or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid))); 

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = read_languagetypeuuid);

RETURN QUERY SELECT 
	loc.locationid, 
	loc.locationcustomerid, 
	cat.custagid as locationcategoryid,
	cat.custagtype as locationcategory,
	lan.systagid as locationlanguagetypeid,
	lan.systagtype as locationlanguagetypename, 
	loc.locationnameid, 
	loc.locationfullname,  
	loc.locationscanid,
	loc.locationlookupname,
	loc.locationtimezone,
	loc.locationsiteid,	
	site.locationfullname as locationsitename,
	loc.locationparentid,	
	parent.locationfullname as locationparentname,	
	loc.locationiscornerstone, 
	loc.locationcornerstoneid,
	corner.locationfullname as locationcornerstonename,  -- join this in
	loc.locationcornerstoneorder, 
	loc.locationstartdate, 
	loc.locationenddate, 
	loc.locationexternalsystemid, 
	loc.locationexternalid
FROM public.view_location loc
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join view_location site
		on site.locationid = loc.locationsiteid
			and site.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join view_location parent
		on parent.locationid = loc.locationparentid
			and parent.languagetranslationtypeid = loc.languagetranslationtypeid
	left join view_location corner
		on corner.locationid = loc.locationcornerstoneid
			and corner.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join custag cat
		on cat.custagid = loc.locationcategoryid
where loc.locationid = read_siteid
	and loc.locationistop = true
	and loc.locationcustomerid = tempcustomerid
	and loc.languagetranslationtypeid = templanguagetypeid;

End;

$function$;


REVOKE ALL ON FUNCTION crud_site_read(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_site_read(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_site_read(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_site_restart(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_site_restart(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

update location
set locationenddate = null,
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where locationid = update_siteid 
		and locationcustomerid = tempcustomerid;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_restart(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_restart(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_restart(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_site_update(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_siteexternaluuid text, IN create_siteexternalsystemuuid text, IN update_sitefullname text, IN update_sitelookupname text, IN update_sitescanid text, IN update_sitetimezone text, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsiteexternalid text;
	templanguagetypeid bigint;
	templocationlanguagetypeid bigint;	
	updatesitelookupname text;
	updatesitescanid text;
	updatesitetimezone text;
Begin

-- We only allow the name,lookupname, scanid, and languagetype to change
-- We will update timezone for now, but not cascade the change.  
-- Timezone changes casue a dangerous cascade to children and workinstances. 

tempcustomeruuid = (select customeruuid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

if update_languagetypeuuid isNull
	then 
		templanguagetypeid =  20;
	else 
		templanguagetypeid = (select systagid from systag where systaguuid = update_languagetypeuuid);
end if;

-- update customer id

CREATE TEMP TABLE tempsite
	(tempsiteid bigint,
   	templanguagemasterid bigint,
	tempsitefullname text,
	tempsitelookupname text,
	tempsitescanid text,
	tempsitetimezone text);

insert into tempsite (
	tempsiteid,
   	templanguagemasterid,
	tempsitefullname,
	tempsitelookupname,
	tempsitescanid,
	tempsitetimezone	
)
select 
	locationid as tempsiteid,
   	locationnameid as templanguagemasterid,
	locationfullname as tempsitefullname,
	locationlookupname as tempsitelookupname,
	locationscanid as tempsitescanid,
	locationtimezone as tempsitetimezone	
from view_location
where languagetranslationtypeid = templanguagetypeid
	and locationcustomerid = tempcustomerid
	and locationid = update_siteid;

-- If the name changed then we update the name in the languagemaster and in the customer tables

if update_sitelookupname isNull
	then
		updatesitelookupname = (select tempsitelookupname from tempsite);
	else
		updatesitelookupname = update_sitelookupname;
end if;

if update_sitescanid isNull
	then
		updatesitescanid = (select tempsitescanid from tempsite);
	else
		updatesitescanid = update_sitescanid;
end if;

if update_sitetimezone isNull
	then
		updatesitetimezone = (select tempsitetimezone from tempsite);
	else
		updatesitetimezone = update_sitetimezone;	
end if;

update languagemaster
set languagemastersource = update_sitefullname,
	languagemastersourcelanguagetypeid = templanguagetypeid,
	languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
	languagemastermodifiedby = update_modifiedbyid,
	languagemastermodifieddate = clock_timestamp()
from tempsite
where tempsiteid = update_siteid
	and templanguagemasterid = languagemasterid
	and tempsitefullname <> update_sitefullname;

update location
	set locationlookupname = updatesitelookupname,
	locationscanid = updatesitescanid,
	locationtimezone = updatesitetimezone
where locationid = update_siteid
	and locationcustomerid = tempcustomerid;

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_update(text,text,text,bigint,text,text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_timesheet_create_customer_v2(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_timesheet_create_customer_v2(IN create_customeruuid text, IN create_siteuuid text, OUT create_adminuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Customer temp values
    tempcustomerid                 bigint := (select customerid from customer where customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp values
    tempcustagsitetypeid           bigint;
    tempcustagsitetypeuuid         text;
    tempsiteid                     bigint := (select locationid from location where locationuuid = create_siteuuid);
    tempsiteuuid                   text;
    tempsitename                   text := (select distinct(locationlookupname) from view_location where locationuuid = create_siteuuid);
    tempsitelanguagemasterid       bigint;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
-- timeclock
    timeclock_config_template_uuid text;
    timeclock_config_uuid          text;

Begin
/*
    RAISE NOTICE 'Start of procedure';

    -- Add in worktemplates for the site id and location types
-- Add in Clock In/Out with entry location type

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Clock In/Out',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part thru template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

select custagid, custaguuid
    into tempcustagsitetypeid, tempcustagsitetypeuuid
    from custag
             inner join customer
                        on custagcustomerid = customerid
    where custagtype = tempsitename
      and (create_customeruuid = custagcustomeruuid
        or tempcustomerid = custagcustomerid);

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            create_modifiedby);

    RAISE NOTICE 'first constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'b2af4084-1f19-4e25-9890-db003ba7a4c3',
            tempworktemplateid,
            883,
            tempcustomerid,
            create_customeruuid);

    RAISE NOTICE 'inserted template';
    -- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby);

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Start Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            2,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"End Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"Start Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Override',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            create_modifiedby);

--"End Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Override',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            create_modifiedby);

--"Override By"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Override By',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            create_modifiedby)
    Returning workresultid into tempworkresultid;

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            create_modifiedby)
    returning workresultid into tempworkresultidforworker;

    -- Add in instances
-- timesheet only has ondemand

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            create_timezone,
            tempsiteid,
            create_modifiedby)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert for tasks
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null);

-- Add in Break In/Out with entry location type

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Break In/Out',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted break in/out template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- 'Row'
                                        worktemplateconstraintconstrainedtypeid, -- Location
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            create_modifiedby);
    RAISE NOTICE 'added second constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'b6efaf15-2818-4e1d-bcc9-26d171496d8d',
            tempworktemplateid,
            884,
            tempcustomerid,
            create_customeruuid);

    -- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby);

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Start Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            2,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"End Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"Start Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Override',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            create_modifiedby);

--"End Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Override',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            create_modifiedby);

--"Override By"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Override By',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            create_modifiedby)
    Returning workresultid into tempworkresultid;

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            create_modifiedby)
    returning workresultid into tempworkresultidforworker;

    RAISE NOTICE 'inserted results';
    -- Add in instances
-- timesheet only has ondemand

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            create_timezone,
            tempsiteid,
            create_modifiedby)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert for tasks
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null);

    RAISE NOTICE 'inserted work instances';
    -- Cleanup widget and format
-- Number
    update workresult
    set workresultwidgetid     = 407,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 701
      and workresultwidgetid is null;

-- Clicker
    update workresult
    set workresultwidgetid     = 406,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 700
      and workresultwidgetid is null;

-- boolean
    update workresult
    set workresultwidgetid     = 414,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 754
      and workresultwidgetid is null;

-- tat
    update workresult
    set workresultwidgetid     = 413,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 737
      and workresultwidgetid is null;

--Text
    update workresult
    set workresultwidgetid     = 408,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 702
      and workresultwidgetid is null;

--Sentiment
    update workresult
    set workresultwidgetid     = 410,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 704
      and workresultwidgetid is null;

--String
    update workresult
    set workresultwidgetid     = 412,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 771
      and workresultwidgetid is null;

-- entity
    update workresult
    set workresultwidgetid     = 415,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 848
      and workresultwidgetid is null;

-- date
    update workresult
    set workresultwidgetid     = 419,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 868
      and workresultwidgetid is null;

-- Geolocation
    update workresult
    set workresultwidgetid     = 463,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 890
      and workresultwidgetid is null;

-- Add in customerconfigs
    select uuid
    into timeclock_config_template_uuid
    from public.crud_customer_config_templates_list(20)
    where category = 'Applications'
      and type = 'Timeclock';

    -- get uuids
    call public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := timeclock_config_template_uuid,
                                            config_value := 'true', modified_by := create_adminuuid,
                                            config_id := timeclock_config_uuid);

    commit;
*/
End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_timesheet_dashboard_list(min_date timestamp with time zone, max_date timestamp with time zone, read_customer_id bigint)
 RETURNS TABLE(worker_name text, worker_first_name text, worker_last_name text, worker_scanid text, worker_id bigint, workinstance_uuid text, template_type text, trust_reason text, start_time timestamp without time zone, start_location_name text, start_override timestamp without time zone, start_override_by text, end_time timestamp without time zone, end_location_name text, end_override timestamp without time zone, end_override_by text, start_display timestamp without time zone, end_display timestamp without time zone, site_timezone text)
 LANGUAGE plpgsql
AS $function$

DECLARE

    maxdate timestamp WITH TIME ZONE;

BEGIN

    --maxdate = (select max(workinstancemodifieddate)
--			from workinstance
--			where workinstancecustomerid = 57); --read_customer_id;

--if (maxdate > now() - interval '1000 minutes')
--	then
    RETURN QUERY
        SELECT foo.worker_name,
               foo.worker_first_name,
               foo.worker_last_name,
               foo.worker_scanid,
               foo.worker_id,
               foo.workinstance_uuid,
               foo.template_type,
               foo.trust_reason,
               foo.start_time,
               foo.start_location_name,
               foo.start_override,
               foo.start_override_by,
               foo.end_time,
               foo.end_location_name,
               foo.end_override,
               foo.end_override_by,
               CASE
                   WHEN foo.start_override IS NULL THEN foo.start_time
                   ELSE foo.start_override
                   END AS start_display,
               CASE
                   WHEN foo.end_override IS NULL THEN foo.end_time
                   ELSE foo.end_override
                   END AS end_display,
               foo.site_timezone
        FROM (SELECT worker.dim_workerfullname                 AS worker_name,
                     worker.dim_workerfirstname                AS worker_first_name,
                     worker.dim_workerlastname                 AS worker_last_name,
                     worker.dim_workerinstancescanid           AS worker_scanid,
                     worker.dim_workerinstanceid               AS worker_id,
                     wi.id                                     AS workinstance_uuid,
                     wtt.dim_worktemplatetypename              AS template_type,
                     tr.dim_trustreasontypename                AS trust_reason,
                     wi.workinstancestartdatetz                AS start_time,
                     locs.dim_locationname                     AS start_location_name, -- added
                     (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                         AT TIME ZONE wi.workinstancetimezone) AS start_override,
                     workerexception.dim_workerfullname        AS start_override_by,
                     wi.workinstancecompleteddatetz            AS end_time,
                     locs.dim_locationname                     AS end_location_name,   -- added
                     (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                         AT TIME ZONE wi.workinstancetimezone) AS end_override,
                     workerexception.dim_workerfullname        AS end_override_by,
                     wi.workinstancetimezone                   AS site_timezone
              FROM public.workinstance AS wi -- public.view_workinstance_full_v2 AS wi
                       INNER JOIN datawarehouse.dim_worktemplate_v2 wt
                                  ON wi.workinstanceworktemplateid = wt.dim_worktemplateid
                                      AND workinstancecustomerid = read_customer_id
                                      AND workinstancestatusid IN (707, 710)
                                      AND wi.workinstancestartdatetz >=
                                          min_date - INTERVAL '14 day' -- whatever stardate is minus 7 days.
--						and (wi.workinstancecompleteddatetz <= max_date + interval '7 day'  -- whatever stardate is minus 7 days.
--								or wi.workinstancecompleteddatetz isNull)
                       INNER JOIN datawarehouse.dim_worktemplatetype wtt
                                  ON wt.dim_dimworktemplatetypeid = wtt.dim_dimworktemplatetypeid
                                      AND wtt.dim_worktemplatetypeid IN (883, 884)
                       LEFT JOIN public.workresultinstance wriesd
                                 ON wriesd.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wriesd.workresultinstanceworkresultid IN
                                         (SELECT dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2
                                          WHERE dim_workresultname = 'Start Override'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       LEFT JOIN PUBLIC.workresultinstance wrieed
                                 ON wrieed.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wrieed.workresultinstanceworkresultid IN
                                         (SELECT dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2
                                          WHERE dim_workresultname = 'End Override'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       INNER JOIN datawarehouse.dim_statustype_v2 AS st
                                  ON wi.workinstancestatusid = st.dim_statustypeid
                                      AND (
                                         -- Case 1: Entry starts within the date range
                                         -- for all of these, we trust the override time if it exists.
                                         (
                                             (wi.workinstancestartdatetz >= min_date::date
                                                 AND wi.workinstancestartdatetz <= max_date::date
                                                 AND wriesd.workresultinstancevalue IS NULL)
                                                 OR
                                             (wriesd.workresultinstancevalue IS NOT NULL
                                                 AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) >= min_date::date
                                                 AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) <= max_date::date)
                                             )
                                             OR
                                             -- Case 2: Entry ends within the date range
                                         (
                                             (wi.workinstancecompleteddatetz >= min_date::date
                                                 AND wi.workinstancecompleteddatetz <= max_date::date
                                                 AND wrieed.workresultinstancevalue ISNULL)
                                                 OR
                                             (wrieed.workresultinstancevalue IS NOT NULL
                                                 AND (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) >= min_date::date
                                                 AND (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) <= max_date::date)
                                             )
                                             OR
                                             -- Case 3: Entry spans the entire date range
                                         (
                                             (
                                                 (wi.workinstancestartdatetz <= min_date::date
                                                     AND wriesd.workresultinstancevalue ISNULL)
                                                     OR
                                                 (wriesd.workresultinstancevalue IS NOT NULL
                                                     AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                         AT TIME ZONE wi.workinstancetimezone) <= min_date::date)
                                                 )
                                                 AND
                                             (
                                                 (wi.workinstancecompleteddatetz >= max_date::date
                                                     AND wrieed.workresultinstancevalue ISNULL)
                                                     OR
                                                 wi.workinstancecompleteddatetz IS NULL
                                                     OR
                                                 (wrieed.workresultinstancevalue IS NOT NULL
                                                     AND (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                                                         AT TIME ZONE wi.workinstancetimezone) >= max_date::date)
                                                 )
                                             )
                                             OR
                                             -- Case 4: Entry is in progress (started before max_date)
                                         (
                                             wi.workinstancestatusid = 707
                                                 AND
                                             (
                                                 (wi.workinstancestartdatetz <= max_date::date
                                                     AND wriesd.workresultinstancevalue ISNULL)
                                                     OR
                                                 (wriesd.workresultinstancevalue IS NOT NULL
                                                     AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                         AT TIME ZONE wi.workinstancetimezone) <= max_date::date)
                                                 )
                                             )
                                         )

                       INNER JOIN datawarehouse.dim_trustreasontype_v2 AS tr
                                  ON wi.workinstancetrustreasoncodeid = tr.dim_trustreasontypeid
                  --                                       AND (wi.workinstancecompleteddatetz ISNULL
--                                           OR ((wi.workinstancecompleteddatetz <= (max_date)::DATE
--                                               AND wrieed.workresultinstancevalue ISNULL)
--                                               OR ((TO_TIMESTAMP(wrieed.workresultinstancevalue::BIGINT / 1000)
--                                                   AT TIME ZONE wi.workinstancetimezone) <= (max_date)::DATE)))
                       INNER JOIN PUBLIC.workresultinstance wris
                                  ON wris.workresultinstanceworkinstanceid = wi.workinstanceid
                                      AND wris.workresultinstanceworkresultid IN
                                          (SELECT dimwr.dim_workresultid
                                           FROM datawarehouse.dim_workresult_v2 dimwr
                                           WHERE dim_workresultname = 'Start Location'
                                             AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       INNER JOIN datawarehouse.dim_location_v2 AS locs
                                  ON wris.workresultinstancevalue::BIGINT = locs.dim_locationid
                       INNER JOIN PUBLIC.location locs2
                                  ON locs2.locationid = locs.dim_locationid
                       LEFT JOIN PUBLIC.workresultinstance wrie
                                 ON wrie.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wrie.workresultinstanceworkresultid IN
                                         (SELECT dimwr.dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2 dimwr
                                          WHERE dim_workresultname = 'End Location'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       LEFT JOIN datawarehouse.dim_location_v2 AS loce
                                 ON wrie.workresultinstancevalue::BIGINT = loce.dim_locationid
                       INNER JOIN PUBLIC.workresultinstance wriw
                                  ON wriw.workresultinstanceworkinstanceid = wi.workinstanceid
                                      AND wriw.workresultinstanceworkresultid IN
                                          (SELECT dim_workresultid
                                           FROM datawarehouse.dim_workresult_v2
                                           WHERE dim_workresultname = 'Worker'
                                             AND dim_dimworktemplateid = wt.dim_dimworktemplateid
                                             AND dim_workresultisprimary = FALSE)
                       INNER JOIN datawarehouse.dim_worker_v2 worker
                                  ON wriw.workresultinstancevalue::BIGINT = worker.dim_workerinstanceid
                       LEFT JOIN PUBLIC.workresultinstance wriwe
                                 ON wriwe.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wriwe.workresultinstanceworkresultid IN
                                         (SELECT dimwr.dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2 dimwr
                                          WHERE dim_workresultname = 'Override By'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid
                                            AND dim_workresultisprimary = FALSE)
                       LEFT JOIN datawarehouse.dim_worker_v2 workerexception
                                 ON wriwe.workresultinstancevalue::BIGINT = workerexception.dim_workerinstanceid) AS foo
        ORDER BY start_time;

END;

$function$;


REVOKE ALL ON FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_timesheet_dashboard_list_bak(min_date timestamp with time zone, max_date timestamp with time zone, customer_id bigint)
 RETURNS TABLE(worker_name text, worker_first_name text, worker_last_name text, worker_scanid text, worker_id bigint, workinstance_uuid text, template_type text, trust_reason text, start_time timestamp without time zone, start_location_name text, start_override timestamp without time zone, start_override_by text, end_time timestamp without time zone, end_location_name text, end_override timestamp without time zone, end_override_by text, start_display timestamp without time zone, end_display timestamp without time zone, site_timezone text)
 LANGUAGE sql
AS $function$

SELECT worker.dim_workerfullname                   AS worker_name,
       worker.dim_workerfirstname                  AS worker_first_name,
       worker.dim_workerlastname                   AS worker_last_name,
       worker.dim_workerinstancescanid             AS worker_scanid,
       worker.dim_workerinstanceid                 AS worker_id,
       w.id                                        AS workinstance_uuid,
       s.systagtype                                AS template_type,
       trusttype.dim_trustreasontypename           AS trust_reason,
       wts.fact_workinstancestartdate              AS start_time,
       loc.dim_locationname                        AS start_location_name,
       wts.fact_workinstanceexceptionstartdate     AS start_override,
       excworker.dim_workerfullname                AS start_override_by,
       --wts.fact_workresultexceptionstartuuid       AS start_override_result_uuid,
       wts.fact_workinstancecompleteddate          AS end_time,
       loc.dim_locationname                        AS end_location_name,
       wts.fact_workinstanceexceptioncompleteddate AS end_override,
       excworker.dim_workerfullname                AS end_override_by,
       wts.fact_workinstancedisplaystartdate       AS start_display,
       wts.fact_workinstancedisplaycompleteddate   AS end_display,
       loc.dim_locationtimezone                    AS site_timezone
--wts.fact_workresultexceptionenduuid         AS end_override_result_uuid
FROM datawarehouse.fact_timesheet wts
         JOIN datawarehouse.dim_customer_v2 cust
              ON wts.dim_dimcustomerid = cust.dim_dimcustomerid
                  AND cust.dim_customerid = customer_id
         INNER JOIN workinstance w
                    ON wts.fact_workinstanceid = w.workinstanceid
                        AND w.workinstancestatusid != 711
         JOIN worktemplate wt ON w.workinstanceworktemplateid = wt.worktemplateid
         JOIN worktemplatetype wtt ON wt.id = wtt.worktemplatetypeworktemplateuuid
         JOIN systag s ON wtt.worktemplatetypesystaguuid = s.systaguuid
         JOIN datawarehouse.dim_location_v2 loc
              ON wts.dim_dimlocationid = loc.dim_dimlocationid
         JOIN datawarehouse.dim_worker_v2 worker
              ON wts.dim_dimworkerid = worker.dim_dimworkerid
         LEFT JOIN datawarehouse.dim_worker_v2 excworker
                   ON wts.dim_dimworkerexceptionid = excworker.dim_dimworkerid
         JOIN datawarehouse.dim_trustreasontype_v2 trusttype
              ON wts.dim_dimtrustreasontypeid = trusttype.dim_dimtrustreasontypeid

WHERE (
          (wts.fact_workinstancedisplaystartdate >= min_date::date
              AND wts.fact_workinstancedisplaystartdate <= max_date::date)
              OR
          (w.workinstancestatusid = 707 -- grab "In Progress" work that was started before the max time
              AND wts.fact_workinstancestartdate <= max_date::date)
          )
ORDER BY wts.fact_workinstancedisplaystartdate;
$function$;


REVOKE ALL ON FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: crud_timesheet_enable_customer(text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_timesheet_enable_customer(IN customer_uuid text, IN site_uuid text, IN modified_by bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- pre-check
    timeclock_enabled              text;
    modified_by_uuid               text;
-- Custoemr temp values
    tempcustomerid                 bigint;
-- Site/Location temp valules
    tempcustagsitetypeid           bigint;
    tempcustagsitetypeuuid         text;
    tempsiteid                     bigint;
    tempsiteuuid                   text;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
    templocationtimezone           text;
-- timeclock
    timeclock_config_template_uuid text;
    timeclock_config_uuid          text;

Begin
    -- first, return if timesheet is already set up for this customer
    select value
    into timeclock_enabled
    from public.crud_customer_config_list(customer_uuid_param := customer_uuid, language_id := 20)
    where category = 'Applications'
      and type = 'Timeclock'
      and value = 'true';

    -- TODO: bolster this handling a little better
    -- need to account for customers turning on/off their features
    -- eventually maybe check if the templates are there?
    if timeclock_enabled notnull
    then
        RAISE NOTICE 'Timeclock already enabled for this customer';
        return;
    End if;


    RAISE NOTICE 'Start of procedure';
    modified_by_uuid = (select workerinstanceuuid from workerinstance w where workerinstanceid = modified_by);

    if modified_by_uuid is null
    then
        RAISE NOTICE 'Unable to find modified by worker';
        return;
    End if;

    -- find customer
    tempcustomerid = (select customerid from customer c where customeruuid = customer_uuid);

    if tempcustomerid is null
    then
        RAISE NOTICE 'Unable to find customer id';
        return;
    End if;

    -- find site
    select locationid, locationcategoryid, locationuuid, custaguuid, locationtimezone
    into tempsiteid, tempcustagsitetypeid, tempsiteuuid, tempcustagsitetypeuuid, templocationtimezone
    from location l
             left join custag c on l.locationcategoryid = c.custagid
    where locationuuid = site_uuid
      and locationcustomerid = tempcustomerid;

    if tempsiteid is null
    then
        RAISE NOTICE 'Unable to find site id';
        return;
    End if;

-- Add in Clock In/Out with entry location type
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Clock In/Out',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            modified_by,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part thru template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            modified_by)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;


-- add the contraints
    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            customer_uuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            modified_by);

    RAISE NOTICE 'first constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            modified_by);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'b2af4084-1f19-4e25-9890-db003ba7a4c3',
            tempworktemplateid,
            883,
            tempcustomerid,
            customer_uuid);

    RAISE NOTICE 'inserted template';
    -- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            modified_by);

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            modified_by);

--"Start Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Location',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            2,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            modified_by);

--"End Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Location',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            modified_by);

--"Start Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Override',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            modified_by);

--"End Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Override',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            modified_by);

--"Override By"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Override By',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            modified_by);

--"Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            modified_by)
    Returning workresultid into tempworkresultid;

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            modified_by)
    returning workresultid into tempworkresultidforworker;

    -- Add in instances
-- timesheet only has ondemand

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            templocationtimezone,
            tempsiteid,
            modified_by)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert for tasks
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            modified_by,
            tempsiteid);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            modified_by,
            null);

-- Add in Break In/Out with entry location type

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Break In/Out',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            modified_by,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted break in/out template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            modified_by)
    Returning workfrequencyid into tempworkfrequencyid;

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- 'Row'
                                        worktemplateconstraintconstrainedtypeid, -- Location
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            customer_uuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            modified_by);
    RAISE NOTICE 'added second constraint';
-- Next template for in progress

    INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                worktemplatenexttemplatenexttemplateid,
                                                worktemplatenexttemplatecustomerid,
                                                worktemplatenexttemplateviastatuschange,
                                                worktemplatenexttemplateviastatuschangeid,
                                                worktemplatenexttemplatesiteid,
                                                worktemplatenexttemplatetypeid,
                                                worktemplatenexttemplatemodifiedby)
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            modified_by);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'b6efaf15-2818-4e1d-bcc9-26d171496d8d',
            tempworktemplateid,
            884,
            tempcustomerid,
            customer_uuid);

    -- Add in workresults here
--"Time At Task"

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresultsiteid,
                                  workresultfortask,
                                  workresultforaudit,
                                  workresulttypeid,
                                  workresultlanguagemasterid,
                                  workresultorder,
                                  workresultisvisible,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            modified_by);

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            modified_by);

--"Start Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Location',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            2,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            modified_by);

--"End Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Location',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            modified_by);

--"Start Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Override',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            modified_by);

--"End Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Override',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            868,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            null,
            FALSE,
            modified_by);

--"Override By"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Override By',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            modified_by);

--"Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            996,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            852,
            TRUE,
            modified_by)
    Returning workresultid into tempworkresultid;

--"Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            modified_by)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.workresult(workresultworktemplateid,
                                  workresultcustomerid,
                                  workresulttypeid,
                                  workresultforaudit,
                                  workresultstartdate,
                                  workresultlanguagemasterid,
                                  workresultsiteid,
                                  workresultorder,
                                  workresultiscalculated,
                                  workresultiseditable,
                                  workresultisvisible,
                                  workresultisrequired,
                                  workresultfortask,
                                  workresultentitytypeid,
                                  workresultisprimary,
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            997,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE,
            850,
            TRUE,
            modified_by)
    returning workresultid into tempworkresultidforworker;

    RAISE NOTICE 'inserted results';
    -- Add in instances
-- timesheet only has ondemand

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            templocationtimezone,
            tempsiteid,
            modified_by)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert for tasks
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            modified_by,
            tempsiteid);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            modified_by,
            null);

    RAISE NOTICE 'inserted work instances';
    -- Cleanup widget and format
-- Number
    update workresult
    set workresultwidgetid     = 407,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 701
      and workresultwidgetid is null;

-- Clicker
    update workresult
    set workresultwidgetid     = 406,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 700
      and workresultwidgetid is null;

-- boolean
    update workresult
    set workresultwidgetid     = 414,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 754
      and workresultwidgetid is null;

-- tat
    update workresult
    set workresultwidgetid     = 413,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 737
      and workresultwidgetid is null;

--Text
    update workresult
    set workresultwidgetid     = 408,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 702
      and workresultwidgetid is null;

--Sentiment
    update workresult
    set workresultwidgetid     = 410,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 704
      and workresultwidgetid is null;

--String
    update workresult
    set workresultwidgetid     = 412,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 771
      and workresultwidgetid is null;

-- entity
    update workresult
    set workresultwidgetid     = 415,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 848
      and workresultwidgetid is null;

-- date
    update workresult
    set workresultwidgetid     = 419,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 868
      and workresultwidgetid is null;

-- Geolocation
    update workresult
    set workresultwidgetid     = 463,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 890
      and workresultwidgetid is null;

-- Add in customerconfigs
    select uuid
    into timeclock_config_template_uuid
    from public.crud_customer_config_templates_list(20)
    where category = 'Applications'
      and type = 'Timeclock';

    -- get uuids
    call public.crud_customer_config_create(customer_uuid := customer_uuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := timeclock_config_template_uuid,
                                            config_value := 'true', modified_by := modified_by_uuid,
                                            config_id := timeclock_config_uuid);

    commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_timesheet_enable_customer(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_timesheet_enable_customer(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_timesheet_enable_customer(text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: crud_timesheet_export_list(timestamp with time zone,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_timesheet_export_list(read_date timestamp with time zone, isenddate boolean, read_customer_id bigint)
 RETURNS TABLE(worker_name text, worker_scanid text, day1_start_date date, day1_clock_start_time timestamp without time zone, day1_break_start_time timestamp without time zone, day1_break_end_time timestamp without time zone, day1_clock_end_time timestamp without time zone, day1_paid_hours numeric, day2_start_date date, day2_clock_start_time timestamp without time zone, day2_break_start_time timestamp without time zone, day2_break_end_time timestamp without time zone, day2_clock_end_time timestamp without time zone, day2_paid_hours numeric, day3_start_date date, day3_clock_start_time timestamp without time zone, day3_break_start_time timestamp without time zone, day3_break_end_time timestamp without time zone, day3_clock_end_time timestamp without time zone, day3_paid_hours numeric, day4_start_date date, day4_clock_start_time timestamp without time zone, day4_break_start_time timestamp without time zone, day4_break_end_time timestamp without time zone, day4_clock_end_time timestamp without time zone, day4_paid_hours numeric, day5_start_date date, day5_clock_start_time timestamp without time zone, day5_break_start_time timestamp without time zone, day5_break_end_time timestamp without time zone, day5_clock_end_time timestamp without time zone, day5_paid_hours numeric, day6_start_date date, day6_clock_start_time timestamp without time zone, day6_break_start_time timestamp without time zone, day6_break_end_time timestamp without time zone, day6_clock_end_time timestamp without time zone, day6_paid_hours numeric, day7_start_date date, day7_clock_start_time timestamp without time zone, day7_break_start_time timestamp without time zone, day7_break_end_time timestamp without time zone, day7_clock_end_time timestamp without time zone, day7_paid_hours numeric)
 LANGUAGE plpgsql
AS $function$

DECLARE
	min_date date;
	max_date date;

BEGIN

-- select * from public.crud_timesheet_export_list('01/06/2025',true,57)
-- select * from public.crud_timesheet_export_list('01/06/2025',false,57)

if isenddate = false
	then
		min_date = read_date;
		max_date = read_date + interval '6 days';
	else
		min_date = read_date - interval '6 days';	
		max_date = read_date;		
end if;


create temp table onerow as 
	(SELECT 	
		clock.worker_name,
		clock.worker_scanid,
		clock.worker_id,		
		clock.start_date,
		clock.start_time as clock_start_time,
		break.start_time as break_start_time,
		clock.end_time as clock_end_time,
		break.end_time as break_end_time,
	   EXTRACT(epoch FROM ((clock.end_time - clock.start_time) - (break.end_time -  break.start_time)))/3600 as paid_hours--,
	FROM (
		SELECT worker.dim_workerfullname AS worker_name,
			worker.dim_workerinstancescanid AS worker_scanid,
			worker.dim_workerinstanceid AS worker_id,
			wtt.dim_worktemplatetypename AS template_type,
			case 
				when wriesd.workresultinstancevalue isNull
					then  wi.workinstancestartdatetz::date
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)::date
			end AS start_date,
			case 
				when wriesd.workresultinstancevalue isNull
					then  wi.workinstancestartdatetz
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)
			end AS start_time,
			case 
				when wrieed.workresultinstancevalue isNull
					then  wi.workinstancecompleteddatetz
				else (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
					 AT TIME ZONE wi.workinstancetimezone)
			end AS end_time,
			wi.workinstancetimezone                   AS site_timezone
		FROM public.workinstance AS wi -- public.view_workinstance_full_v2 AS wi
			INNER JOIN datawarehouse.dim_worktemplate_v2 wt
				ON wi.workinstanceworktemplateid = wt.dim_worktemplateid
					AND workinstancecustomerid = read_customer_id
					AND workinstancestatusid IN (707, 710)
					AND wi.workinstancestartdatetz >=
					  min_date::date - INTERVAL '14 day' -- whatever stardate is minus 7 days.
			INNER JOIN datawarehouse.dim_worktemplatetype wtt
				ON wt.dim_dimworktemplatetypeid = wtt.dim_dimworktemplatetypeid
					AND wtt.dim_worktemplatetypeid IN (883)
			LEFT JOIN public.workresultinstance wriesd
				ON wriesd.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriesd.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Start Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			INNER JOIN datawarehouse.dim_statustype_v2 AS st
				ON wi.workinstancestatusid = st.dim_statustypeid
					AND ((wi.workinstancestartdatetz >= min_date::date
							AND wi.workinstancestartdatetz <= max_date::date
							AND wriesd.workresultinstancevalue ISNULL)
						OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) >= min_date::date)
						AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) <= max_date::date
						OR (wi.workinstancestatusid = 707
							AND ((wi.workinstancestartdatetz <= max_date::date
								AND wriesd.workresultinstancevalue ISNULL)
								OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
									AT TIME ZONE wi.workinstancetimezone) <= max_date::date))))
			LEFT JOIN PUBLIC.workresultinstance wrieed
				ON wrieed.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrieed.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'End Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			INNER JOIN datawarehouse.dim_trustreasontype_v2 AS tr
				ON wi.workinstancetrustreasoncodeid = tr.dim_trustreasontypeid
			INNER JOIN PUBLIC.workresultinstance wris
				ON wris.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wris.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'Start Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN PUBLIC.workresultinstance wrie
				ON wrie.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrie.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'End Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN datawarehouse.dim_location_v2 AS loce
				ON wrie.workresultinstancevalue::BIGINT = loce.dim_locationid
			INNER JOIN PUBLIC.workresultinstance wriw
				ON wriw.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriw.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Worker'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid
							AND dim_workresultisprimary = FALSE)
			INNER JOIN datawarehouse.dim_worker_v2 worker
			  	ON wriw.workresultinstancevalue::BIGINT = worker.dim_workerinstanceid) AS clock
	left join (
		SELECT 
			worker.dim_workerfullname AS worker_name,
			worker.dim_workerinstancescanid AS worker_scanid,
			worker.dim_workerinstanceid AS worker_id,
			wtt.dim_worktemplatetypename AS template_type,
			case 
				when wriesd.workresultinstancevalue isNull
					then wi.workinstancestartdatetz::date
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
					AT TIME ZONE wi.workinstancetimezone)::date
			end AS start_date,
			case 
				when wriesd.workresultinstancevalue isNull
					then  wi.workinstancestartdatetz
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)
			end AS start_time,
			case 
				when wrieed.workresultinstancevalue isNull
					then wi.workinstancecompleteddatetz
				else (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)
				end AS end_time,
			wi.workinstancetimezone                   AS site_timezone
		FROM public.workinstance wi
			INNER JOIN datawarehouse.dim_worktemplate_v2 wt
				ON wi.workinstanceworktemplateid = wt.dim_worktemplateid
					AND workinstancecustomerid = read_customer_id
					AND workinstancestatusid IN (707, 710)
					AND wi.workinstancestartdatetz >=
						min_date::date - INTERVAL '14 day' -- whatever stardate is minus 7 days.
			INNER JOIN datawarehouse.dim_worktemplatetype wtt
				ON wt.dim_dimworktemplatetypeid = wtt.dim_dimworktemplatetypeid
					AND wtt.dim_worktemplatetypeid IN (884)
			LEFT JOIN public.workresultinstance wriesd
				ON wriesd.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriesd.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Start Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
						INNER JOIN datawarehouse.dim_statustype_v2 AS st
				ON wi.workinstancestatusid = st.dim_statustypeid
					AND ((wi.workinstancestartdatetz >= min_date::date
							AND wi.workinstancestartdatetz <= max_date::date
							AND wriesd.workresultinstancevalue ISNULL)
						OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) >= min_date::date)
						AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) <= max_date::date
						OR (wi.workinstancestatusid = 707
							AND ((wi.workinstancestartdatetz <= max_date::date
								AND wriesd.workresultinstancevalue ISNULL)
								OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
									AT TIME ZONE wi.workinstancetimezone) <= max_date::date))))
			LEFT JOIN PUBLIC.workresultinstance wrieed
				ON wrieed.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrieed.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'End Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			INNER JOIN datawarehouse.dim_trustreasontype_v2 AS tr
				ON wi.workinstancetrustreasoncodeid = tr.dim_trustreasontypeid
			INNER JOIN PUBLIC.workresultinstance wris
				ON wris.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wris.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'Start Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN PUBLIC.workresultinstance wrie
				ON wrie.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrie.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'End Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN datawarehouse.dim_location_v2 AS loce
				ON wrie.workresultinstancevalue::BIGINT = loce.dim_locationid
			INNER JOIN PUBLIC.workresultinstance wriw
				ON wriw.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriw.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Worker'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid
							AND dim_workresultisprimary = FALSE)
			INNER JOIN datawarehouse.dim_worker_v2 worker
			  	ON wriw.workresultinstancevalue::BIGINT = worker.dim_workerinstanceid) AS break
		on clock.worker_id = break.worker_id
			and clock.start_date = break.start_date
	ORDER BY clock_start_time);

create temp table workerlist as 
	(select 
		orow.worker_name,
		orow.worker_scanid,
		orow.worker_id
	from onerow orow
	group by orow.worker_name,	orow.worker_scanid, orow.worker_id);

RETURN QUERY 
	select 
		wl.worker_name,
		wl.worker_scanid,
		min_date as day1_start_date,
		day1.clock_start_time as day1_clock_start_time,
		day1.break_start_time as day1_break_start_time,
		day1.clock_end_time as day1_clock_end_time,
		day1.break_end_time as day1_break_end_time,
		day1.paid_hours as day1_paid_hours,
		(min_date + interval '1 day')::date as day2_start_date,
		day2.clock_start_time as day2_clock_start_time,
		day2.break_start_time as day2_break_start_time,
		day2.clock_end_time as day2_clock_end_time,
		day2.break_end_time as day2_break_end_time,
		day2.paid_hours as day2_paid_hours,
		(min_date + interval '2 day')::date as day3_start_date,
		day3.clock_start_time as day3_clock_start_time,
		day3.break_start_time as day3_break_start_time,
		day3.clock_end_time as day3_clock_end_time,
		day3.break_end_time as day3_break_end_time,
		day3.paid_hours as day3_paid_hours,
		(min_date + interval '3 day')::date as day4_start_date,
		day4.clock_start_time as day4_clock_start_time,
		day4.break_start_time as day4_break_start_time,
		day4.clock_end_time as day4_clock_end_time,
		day4.break_end_time as day4_break_end_time,
		day4.paid_hours as day4_paid_hours,
		(min_date + interval '4 day')::date as day5_start_date,
		day5.clock_start_time as day5_clock_start_time,
		day5.break_start_time as day5_break_start_time,
		day5.clock_end_time as day5_clock_end_time,
		day5.break_end_time as day5_break_end_time,
		day5.paid_hours as day5_paid_hours,
		(min_date + interval '5 day')::date  as day6_start_date,
		day6.clock_start_time as day6_clock_start_time,
		day6.break_start_time as day6_break_start_time,
		day6.clock_end_time as day6_clock_end_time,
		day6.break_end_time as day6_break_end_time,
		day6.paid_hours as day6_paid_hours,
		(min_date + interval '6 day')::date  as day7_start_date,
		day7.clock_start_time as day7_clock_start_time,
		day7.break_start_time as day7_break_start_time,
		day7.clock_end_time as day7_clock_end_time,
		day7.break_end_time as day7_break_end_time,
		day7.paid_hours as day7_paid_hours
	from workerlist wl
		left join onerow day1
			on wl.worker_id = day1.worker_id
				and day1.start_date::date = min_date
		left join onerow day2
			on wl.worker_id = day2.worker_id
				and day2.start_date = min_date + interval '1 day'
		left join onerow day3
			on wl.worker_id = day3.worker_id
				and day3.start_date = min_date + interval '2 day'
		left join onerow day4
			on wl.worker_id = day4.worker_id
				and day4.start_date = min_date + interval '3 day'
		left join onerow day5
			on wl.worker_id = day5.worker_id
				and day5.start_date = min_date + interval '4 day'
		left join onerow day6
			on wl.worker_id = day6.worker_id
				and day6.start_date = min_date + interval '5 day'
		left join onerow day7
			on wl.worker_id = day7.worker_id
				and day7.start_date = min_date + interval '6 day'
	order by wl.worker_name, wl.worker_scanid;

drop table onerow;
drop table workerlist;

END;

$function$;


REVOKE ALL ON FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: enable_runtime(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.enable_runtime(customer_id text, site_uuid text, language_type text, modified_by bigint, timezone text)
 RETURNS TABLE(op text, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  ins_locations text[];
  --
  ins_template text;
  --
  loop0_x text;
  --
  runtime_config_template_uuid text;
  --
  runtime_config_uuid text;
begin
/*
  perform set_config('user.id', workeridentityid, true)
  from public.workerinstance
  inner join public.worker on workerinstanceworkerid = workerid
  where workerinstanceid = modified_by;

  with
        inputs(location_name, location_typename) as (
            values
                ('My First Location'::text, 'Runtime Location'::text)
        )
    select array_agg(t.id) into ins_locations
    from
        inputs,
        public.create_location(
            customer_id := customer_id,
            language_type := language_type,
            timezone := timezone,
            location_name := inputs.location_name,
            location_parent_id := site_uuid,
            location_typename := inputs.location_typename,
            modified_by := modified_by
        ) as t
    ;
  --

  select t.id into ins_template
  from legacy0.create_task_t(
      customer_id := customer_id,
      language_type := language_type,
      task_name := 'Run',
      task_parent_id := site_uuid,
      modified_by := modified_by
  ) as t;
  --
  if not found then
    raise exception 'failed to create template';
  end if;
  --
  return query select ' +task', ins_template;

  return query
    select '  +type', t.id
    from
        public.systag as s,
        legacy0.create_template_type(
            template_id := ins_template,
            systag_id := s.systaguuid,
            modified_by := modified_by
        ) as t
    where s.systagparentid = 882 and s.systagtype in ('Trackable', 'Runtime')
  ;
  --
  if not found then
    raise exception 'failed to create template type';
  end if;

  return query
    with field (f_name, f_type, f_is_primary, f_order) as (
        values
            ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
            ('Override End Time', 'Date', true, 1),
            ('Run Output', 'Number', false, 2),
            ('Reject Count', 'Number', false, 3),
            ('Comments', 'String', false, 99)
    )
    select '  +field', t.id
    from
        field,
        legacy0.create_field_t(
            customer_id := customer_id,
            language_type := language_type,
            template_id := ins_template,
            field_description := null,
            field_is_draft := false,
            field_is_primary := field.f_is_primary,
            field_is_required := false,
            field_name := field.f_name,
            field_order := field.f_order,
            field_reference_type := null,
            field_type := field.f_type,
            field_value := null,
            field_widget := null,
            modified_by := modified_by
        ) as t
  ;
  --
  if not found then
    raise exception 'failed to create template fields';
  end if;

  -- The canonical on-demand in-progress "respawn" rule. This rule causes a new,
  -- Open task instance to be created when a task transitions to InProgress.
  return query
    select '  +irule', t.next
    from legacy0.create_instantiation_rule(
        prev_template_id := ins_template,
        next_template_id := ins_template,
        state_condition := 'In Progress',
        type_tag := 'On Demand',
        modified_by := modified_by
    ) as t;
  --
  if not found then
    raise exception 'failed to create canonical on-demand in-progress irule';
  end if;

  -- Create the constraint for the root template at each child location.
   <<loop0>>
   foreach loop0_x in array ins_locations loop
     return query
       with
           ins_constraint as (
               select *
               from legacy0.create_template_constraint_on_location(
                   template_id := ins_template,
                   location_id := loop0_x,
                   modified_by := modified_by
               ) as t
           ),

           ins_instance as (
               select *
               from engine0.instantiate(
                   template_id := ins_template,
                   location_id := loop0_x,
                   target_state := 'Open',
                   target_type := 'On Demand',
                   modified_by := modified_by
               )
           )

       select '  +constraint', t.id
       from ins_constraint as t
       union all
       (
         select '   +instance', t.instance
         from ins_instance as t
         group by t.instance
       )
     ;
   end loop loop0;
  --
  if not found then
    raise exception 'failed to create location constraint/initial instance';
  end if;

  -- Create the Idle Time template, which is a transition from public.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := customer_id,
                language_type := language_type,
                task_name := 'Idle Time',
                task_parent_id := site_uuid,
                task_order := 1,
                modified_by := modified_by
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Idle Time'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_next.id,
                    field_description := null,
                    field_is_draft := false,
                    field_is_primary := field.f_is_primary,
                    field_is_required := false,
                    field_name := field.f_name,
                    field_order := field.f_order,
                    field_reference_type := null,
                    field_type := field.f_type,
                    field_value := null,
                    field_widget := null,
                    modified_by := modified_by
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand',
                    modified_by := modified_by
                ) as t
        ),

        ins_constraint as (
            select t.*
            from
                unnest(ins_locations) as ins_location(id),
                ins_next,
                legacy0.create_template_constraint_on_location(
                    template_id := ins_next.id,
                    location_id := ins_location.id,
                    modified_by := modified_by
                ) as t
        )

        select '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Idle Time)';
  end if;

  -- Create the Downtime template, which is a transition from public.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := customer_id,
                language_type := language_type,
                task_name := 'Downtime',
                task_parent_id := site_uuid,
                task_order := 0,
                modified_by := modified_by
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Downtime'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_next.id,
                    field_description := null,
                    field_is_draft := false,
                    field_is_primary := field.f_is_primary,
                    field_is_required := false,
                    field_name := field.f_name,
                    field_order := field.f_order,
                    field_reference_type := null,
                    field_type := field.f_type,
                    field_value := null,
                    field_widget := null,
                    modified_by := modified_by
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand',
                    modified_by := modified_by
                ) as t
        ),

        ins_constraint as (
            select t.*
            from
                unnest(ins_locations) as ins_location(id),
                ins_next,
                legacy0.create_template_constraint_on_location(
                    template_id := ins_next.id,
                    location_id := ins_location.id,
                    modified_by := modified_by
                ) as t
        )

        select '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Downtime)';
  end if;

  select uuid
  into runtime_config_template_uuid
  from public.crud_customer_config_templates_list(20)
  where category = 'Applications'
  and type = 'Runtime';

  -- get uuids
  call public.crud_customer_config_create(
      customer_uuid := customer_id,
      site_uuid := site_uuid,
      config_template_uuid := runtime_config_template_uuid,
      config_value := 'true'::text,
      modified_by := null,
      config_id := runtime_config_uuid
      );
*/
  return;
end
$function$;


REVOKE ALL ON FUNCTION enable_runtime(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION enable_runtime(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION enable_runtime(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_read_rtls_last_known_location(timestamp with time zone,text[],text[],text[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_rtls_last_known_location(read_enddate timestamp with time zone, read_customeruuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
 RETURNS TABLE(workinstanceid bigint, workinstanceuuid text, workinstancecustomerid bigint, workinstanceworktemplateid bigint, workinstancesiteid bigint, workinstancepreviousid bigint, workinstanceoriginatorworkinstanceid bigint, workinstancestartdate timestamp with time zone, workinstancecompleteddate timestamp with time zone, workinstanceexternalid text, workinstancetimezone text, locationid bigint, workerinstanceid bigint, workerinstanceuuid text, latitude numeric, longitude numeric, onlinestatus text, accuracy numeric, altitude numeric, altaccuracy numeric, heading numeric, speed numeric, previousworkinstanceexternalid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

tempworkerarray bigint[];
templocationarray bigint[];
tempcustomerarray text[];
tempworkinstance text[];
tempstardate timestamp with time zone;
tempenddate timestamp with time zone;

BEGIN

/*

-- future add in language type (For now hardcoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_read_rtls_last_known_location(null,null,null, null)

-- send in an array of customeruuids
select * from public.func_read_rtls_last_known_location(null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null, null)

-- send in an array of locationuuids
select * from public.func_read_rtls_last_known_location(null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_read_rtls_last_known_location(null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_read_rtls_last_known_location(null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_last_known_location('11/1/2024',ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

*/

if (read_customeruuidarray isNull or array_length(read_customeruuidarray, 1) = 0)
	then tempcustomerarray = ARRAY(
		select customeruuid
		from customerconfig
			inner join customer
				on customerconfigcustomeruuid = customeruuid
					and customerconfigvalue = 'true'
			inner join systag t
				on t.systaguuid = customerconfigtypeuuid
					and t.systagtype = 'RTLS'
			inner join systag category on t.systagparentid = category.systagid );
	else tempcustomerarray = read_customeruuidarray;
End if;

tempenddate =
	case
		when read_enddate isnull
			then clock_timestamp()
		else read_enddate
	end;

tempstardate = tempenddate - interval '4 days';

return query
select fullrecords.*
from (select wri.workresultinstancevalue as maxworkerid, max(wi.workinstancecompleteddate) as maxdate
		from worktemplate wt
			inner join worktemplatetype wtt
				on wtt.worktemplatetypeworktemplateuuid = id
					and wtt.worktemplatetypecustomeruuid = any (tempcustomerarray)
					and wtt.worktemplatetypesystaguuid = 'f0d0bca1-827a-46da-80bc-af1c8ef914db'
			inner join workresult wr
				on wt.worktemplateid = wr.workresultworktemplateid
					AND wr.workresulttypeid = 848
					AND wr.workresultentitytypeid = 850
					AND wr.workresultisprimary = true
			inner join workinstance wi
				on wt.worktemplateid = wi.workinstanceworktemplateid
					and wi.workinstancestartdate > tempstardate
					and wi.workinstancecompleteddate < tempenddate
			inner join workresultinstance wri
				on wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = wr.workresultid
					and wri.workresultinstancevalue notNull
		group by wri.workresultinstancevalue) maxrecords
	inner join (select * from public.func_readrtls(tempstardate, tempenddate, null, tempcustomerarray, null, read_locationuuidarray, read_workerinstanceuuidarray)) fullrecords
				on maxworkerid::bigint = fullrecords.workerinstanceid
					and maxdate = fullrecords.workinstancecompleteddate;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_rtls_last_known_location(timestamp with time zone,text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_last_known_location(timestamp with time zone,text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_last_known_location(timestamp with time zone,text[],text[],text[]) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_rtls_nth_record(read_startdate timestamp with time zone, read_enddate timestamp with time zone, read_originationidarray bigint[], read_customeruuidarray text[], read_workinstanceuuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
 RETURNS TABLE(workinstanceid bigint, workinstanceuuid text, workinstancecustomerid bigint, workinstanceworktemplateid bigint, workinstancesiteid bigint, workinstancepreviousid bigint, workinstanceoriginatorworkinstanceid bigint, workinstancestartdate timestamp with time zone, workinstancecompleteddate timestamp with time zone, workinstanceexternalid text, workinstancetimezone text, locationid bigint, workerinstanceid bigint, workerinstanceuuid text, latitude numeric, longitude numeric, onlinestatus text, accuracy numeric, altitude numeric, altaccuracy numeric, heading numeric, speed numeric, previousworkinstanceexternalid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

tempworkerarray bigint[];
templocationarray bigint[];
tempcustomerarray text[];
tempworkinstanceidarray bigint[];
tempworkinstancearray text[];
tempstardate timestamp with time zone;
tempenddate timestamp with time zone;
tempfactor bigint;

BEGIN

/*

-- future add in language type (For now hardcoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_read_rtls_nth_record(null,null,null, null,null,null, null)

-- send in an array of customeruuids
select * from public.func_read_rtls_nth_record(null,null,null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,null, null)

-- send in an array of locationuuids
select * from public.func_read_rtls_nth_record(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_read_rtls_nth_record(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_read_rtls_nth_record('10/27/2024',null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record(null,'10/27/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record('10/27/2024','10/28/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in originationid
select * from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],
			null,null,null, null)
select count(*) from workinstance where workinstanceoriginatorworkinstanceid = 2079961

-- send in workinstances
select * from public.func_read_rtls_nth_record(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- group by originationid
select wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone,min(wi.workinstancestartdate), count(*)
from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18']) as wi
group by wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone

*/

if (read_customeruuidarray isNull or array_length(read_customeruuidarray, 1) = 0)
	then tempcustomerarray = ARRAY(
		select customeruuid
		from customerconfig
			inner join customer
				on customerconfigcustomeruuid = customeruuid
					and customerconfigvalue = 'true'
			inner join systag t
				on t.systaguuid = customerconfigtypeuuid
					and t.systagtype = 'RTLS'
			inner join systag category on t.systagparentid = category.systagid );
	else tempcustomerarray = read_customeruuidarray;
End if;

-- eventually move this to uuid or even entity
-- I think this does not work.  Return to it.

if (read_locationuuidarray isNull or array_length(read_locationuuidarray, 1) = 0)
	then templocationarray = ARRAY(
		select loc.locationid from location loc
		where loc.locationcustomerid in (select customerid from customer
									where customeruuid = any (tempcustomerarray))); -- replace this with a call to get all rtls locations for the customers
	else templocationarray = ARRAY(
		select lo2.locationid from location lo2
		where lo2.locationuuid = any (read_locationuuidarray));
End if;

-- Should we skip this?

if (read_workerinstanceuuidarray isNull or array_length(read_workerinstanceuuidarray, 1) = 0)
	then tempworkerarray = ARRAY(
		select worker_instance2.workerinstanceid from workerinstance worker_instance2
		where worker_instance2.workerinstancecustomerid in (select customerid from customer
										where customeruuid = any (tempcustomerarray)));
	else tempworkerarray = ARRAY(
		select worker_instance3.workerinstanceid from workerinstance worker_instance3
		where worker_instance3.workerinstanceuuid = any (read_workerinstanceuuidarray));
End if;

tempstardate =
	case
		when read_startdate isnull
			then '01/01/1900'
		else read_startdate
	end;

tempenddate =
	case
		when read_enddate isnull
			then clock_timestamp()
		else read_enddate
	end;

-- I need to add usage of location id.  Forgot to do this.

if (read_originationidarray isNull or array_length(read_originationidarray, 1) = 0)
		and (read_workinstanceuuidarray isNull or array_length(read_workinstanceuuidarray, 1) = 0)
	then create temp table tempworkinstancetable as
		(select wi.workinstanceid, wi.id, wi.workinstancecompleteddate, wi.workinstanceoriginatorworkinstanceid
			FROM workinstance wi
				join public.worktemplatetype wtt
					on wi.workinstanceworktemplateid = wtt.worktemplatetypeworktemplateid
						and worktemplatetypesystaguuid in ('f0d0bca1-827a-46da-80bc-af1c8ef914db')  -- RTLS
						and worktemplatetypecustomeruuid = any (tempcustomerarray)  -- Customer
						and wi.workinstancestatusid in (707,710)  -- in progress or Completed
						and wi.workinstancetrustreasoncodeid = 762  -- Trusted
						and wi.workinstancestartdate > tempstardate
						and wi.workinstancestartdate < tempenddate
						and wi.workinstancecompleteddate > tempstardate
						and wi.workinstancecompleteddate < tempenddate
			order by wi.workinstanceid	);
	else  create temp table tempworkinstancetable as
				(select wi2.workinstanceid, wi2.id, wi2.workinstancecompleteddate, wi2.workinstanceoriginatorworkinstanceid
				from workinstance wi2
				where wi2.workinstanceoriginatorworkinstanceid = any(read_originationidarray)
				order by wi2.workinstanceid);
end if;

if (select count(*) from tempworkinstancetable) <= 100
	then tempfactor = 1;
	else tempfactor = ((select count(*) from tempworkinstancetable) / 100);
end if;

create temp table tempworkinstancetable2 as
(select nbrrows.workinstanceid, nbrrows.id, nbrrows.workinstanceoriginatorworkinstanceid, nbrrows.workinstancecompleteddate
	from (select row_number() OVER(ORDER BY t.workinstancecompleteddate desc) AS rownbr , *
			from tempworkinstancetable t ) nbrrows
	WHERE (nbrrows.rownbr - 1) % tempfactor = 0
union
select maxrecord.workinstanceid, maxrecord.id, maxrecord.workinstanceoriginatorworkinstanceid, maxtable.maxdate as workinstancecompleteddate
	from tempworkinstancetable maxrecord
		inner join (select twt.workinstanceoriginatorworkinstanceid as originator, max(twt.workinstancecompleteddate) as maxdate
					from tempworkinstancetable twt
					group by twt.workinstanceoriginatorworkinstanceid) as maxtable
			on maxtable.originator = maxrecord.workinstanceoriginatorworkinstanceid
				and maxtable.maxdate = maxrecord.workinstancecompleteddate
union
select minrecord.workinstanceid, minrecord.id, minrecord.workinstanceoriginatorworkinstanceid, mintable.mindate as workinstancecompleteddate
	from tempworkinstancetable minrecord
		inner join (select twt2.workinstanceoriginatorworkinstanceid as originator, min(twt2.workinstancecompleteddate) as mindate
					from tempworkinstancetable twt2
					group by twt2.workinstanceoriginatorworkinstanceid) as mintable
			on mintable.originator = minrecord.workinstanceoriginatorworkinstanceid
				and mintable.mindate = minrecord.workinstancecompleteddate
							);

return query
select
	returnrecord.workinstanceid,
	 returnrecord.workinstanceuuid,
	 returnrecord.workinstancecustomerid,
	 returnrecord.workinstanceworktemplateid,
	 returnrecord.workinstancesiteid,
	 returnrecord.workinstancepreviousid,
	 returnrecord.workinstanceoriginatorworkinstanceid,
	 returnrecord.workinstancestartdate,
	 returnrecord.workinstancecompleteddate,
	 returnrecord.workinstanceexternalid,
	 returnrecord.workinstancetimezone,
	 returnrecord.locationid,
	 returnrecord.workerinstanceid,
	 returnrecord.workerinstanceuuid,
	 returnrecord.latitude,
	 returnrecord.longitude,
	 returnrecord.onlinestatus,
	 returnrecord.accuracy,
	 returnrecord.altitude,
	 returnrecord.altaccuracy,
	 returnrecord.heading,
	 returnrecord.speed,
	 returnrecord.previousworkinstanceexternalid
	from public.func_readrtls(
		read_startdate,
		read_enddate,
		read_originationidarray,
		read_customeruuidarray,
		null,
		read_locationuuidarray,  -- replace this once this is fixed.
		read_workerinstanceuuidarray -- replace this once this is fixed.
			) as returnrecord
			inner join tempworkinstancetable2 rt2
				on rt2.workinstanceid = returnrecord.workinstanceid;

drop table tempworkinstancetable;
drop table tempworkinstancetable2;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_rtls_start_date_helper(read_enddate timestamp with time zone, read_customeruuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
 RETURNS TABLE(workinstanceid bigint, workinstanceuuid text, workinstancecustomerid bigint, workinstanceworktemplateid bigint, workinstancesiteid bigint, workinstancepreviousid bigint, workinstanceoriginatorworkinstanceid bigint, workinstancestartdate timestamp with time zone, workinstancecompleteddate timestamp with time zone, workinstanceexternalid text, workinstancetimezone text, locationid bigint, workerinstanceid bigint, workerinstanceuuid text, latitude numeric, longitude numeric, onlinestatus text, accuracy numeric, altitude numeric, altaccuracy numeric, heading numeric, speed numeric, previousworkinstanceexternalid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

tempworkerarray bigint[];
templocationarray bigint[];
tempcustomerarray text[];
tempworkinstance text[];
tempstardate timestamp with time zone;
tempenddate timestamp with time zone;

BEGIN

/*

-- future add in language type (For now hardcoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_read_rtls_last_known_location(null,null,null, null)

-- send in an array of customeruuids
select * from public.func_read_rtls_last_known_location(null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null, null)

-- send in an array of locationuuids
select * from public.func_read_rtls_last_known_location(null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_read_rtls_last_known_location(null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_read_rtls_last_known_location(null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_last_known_location('11/1/2024',ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

*/

if (read_customeruuidarray isNull or array_length(read_customeruuidarray, 1) = 0)
	then tempcustomerarray = ARRAY(
		select customeruuid
		from customerconfig
			inner join customer
				on customerconfigcustomeruuid = customeruuid
					and customerconfigvalue = 'true'
			inner join systag t
				on t.systaguuid = customerconfigtypeuuid
					and t.systagtype = 'RTLS'
			inner join systag category on t.systagparentid = category.systagid );
	else tempcustomerarray = read_customeruuidarray;
End if;

tempenddate =
	case
		when read_enddate isnull
			then clock_timestamp()
		else read_enddate
	end;

tempstardate = tempenddate - interval '4 days';

return query
select fullrecords.*
from (select wri.workresultinstancevalue as maxworkerid, min(wi.workinstancecompleteddate) as maxdate
		from worktemplate wt
			inner join worktemplatetype wtt
				on wtt.worktemplatetypeworktemplateuuid = id
					and wtt.worktemplatetypecustomeruuid = any (tempcustomerarray)
					and wtt.worktemplatetypesystaguuid = 'f0d0bca1-827a-46da-80bc-af1c8ef914db'
			inner join workresult wr
				on wt.worktemplateid = wr.workresultworktemplateid
					AND wr.workresulttypeid = 848
					AND wr.workresultentitytypeid = 850
					AND wr.workresultisprimary = true
			inner join workinstance wi
				on wt.worktemplateid = wi.workinstanceworktemplateid
					and wi.workinstancestartdate > tempstardate
					and wi.workinstancecompleteddate < tempenddate
			inner join workresultinstance wri
				on wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = wr.workresultid
					and wri.workresultinstancevalue notNull
		group by wri.workresultinstancevalue) maxrecords
	inner join (select * from public.func_readrtls(tempstardate, tempenddate, null, tempcustomerarray, null, read_locationuuidarray, read_workerinstanceuuidarray)) fullrecords
				on maxworkerid::bigint = fullrecords.workerinstanceid
					and maxdate = fullrecords.workinstancecompleteddate;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_read_workresultinstancevalues_bigint(text[],text,text,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_workresultinstancevalues_bigint(func_workinstanceuuidarray text[], func_workresultuuid text, func_workresultname text, func_primaryaccuracy boolean)
 RETURNS TABLE(workresultinstancecustomerid bigint, workresultinstanceworkinstanceid bigint, workresultinstancevalue bigint)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	tempworkresultid bigint[];
BEGIN

/*

-- send in the result name
select * from public.func_read_workresultinstancevalues_bigint(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	null,'Location', true)

*/

-- figure out the workresultid

if func_workresultuuid notNull
	then tempworkresultid = ARRAY(select workresultid from workresult
								where id = func_workresultuuid);
	else tempworkresultid = ARRAY(select workresultid from view_workresult
								where workresultname = func_workresultname
									and workresultworktemplateid in (select distinct workinstanceworktemplateid
																		from workinstance wi
																		where wi.id = any  (func_workinstanceuuidarray))
									and workresultisprimary = func_primaryaccuracy
									and languagetranslationtypeid = 20);
end if;


create temp table tempwri
as
select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue
from workinstance wi
	inner join workresultinstance wri
		on wi.id = any (func_workinstanceuuidarray)
			and wri.workresultinstanceworkinstanceid = wi.workinstanceid
			and wri.workresultinstanceworkresultid = any (tempworkresultid)
group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue;

return query
	select pl.workresultinstancecustomerid, pl.workresultinstanceworkinstanceid, pl.workresultinstancevalue::bigint
			from tempwri pl;

drop table tempwri;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_workresultinstancevalues_bigint(text[],text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_bigint(text[],text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_bigint(text[],text,text,boolean) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_read_workresultinstancevalues_numeric(text[],text,text,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_workresultinstancevalues_numeric(func_workinstanceuuidarray text[], func_workresultuuid text, func_workresultname text, func_primaryaccuracy boolean)
 RETURNS TABLE(workresultinstancecustomerid bigint, workresultinstanceworkinstanceid bigint, workresultinstancevalue numeric)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	tempworkresultid bigint[];
BEGIN

/*

-- send in the result name
select * from public.func_read_workresultinstancevalues_bigint(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	null,'Location', true)

*/

-- figure out the workresultid

if func_workresultuuid notNull
	then tempworkresultid = ARRAY(select workresultid from workresult
								where id = func_workresultuuid);
	else tempworkresultid = ARRAY(select workresultid from view_workresult
								where workresultname = func_workresultname
									and workresultworktemplateid in (select distinct workinstanceworktemplateid
																		from workinstance wi
																		where wi.id = any  (func_workinstanceuuidarray))
									and workresultisprimary = func_primaryaccuracy
									and languagetranslationtypeid = 20);
end if;


create temp table tempwri
as
select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue
from workinstance wi
	inner join workresultinstance wri
		on wi.id = any (func_workinstanceuuidarray)
			and wri.workresultinstanceworkinstanceid = wi.workinstanceid
			and wri.workresultinstanceworkresultid = any (tempworkresultid)
group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue;

return query
	select pl.workresultinstancecustomerid, pl.workresultinstanceworkinstanceid, pl.workresultinstancevalue::numeric
			from tempwri pl;

drop table tempwri;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_read_workresultinstancevalues_text(text[],text,text,text,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_workresultinstancevalues_text(func_workinstanceuuidarray text[], func_workresultuuid text, func_workresultname text, func_workresultinstancevaluelanguagetypeuuid text, func_primaryaccuracy boolean)
 RETURNS TABLE(workresultinstancecustomerid bigint, workresultinstanceworkinstanceid bigint, workresultinstancevalue text, workresultinstancevaluelanguagemasterid bigint, workresultinstancevaluelanguagetypeuuid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	templanguagetypeid bigint;
	tempworkresultid bigint[];
BEGIN

/*

-- send in the result name
select * from public.func_read_workresultinstancevalues_text(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	null,'RTLS - Online Status',	'7ebd10ee-5018-4e11-9525-80ab5c6aebee',false)

-- send in the resultuuid

select * from public.func_read_workresultinstancevalues_text(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	'work-result_c3483075-d2b5-4324-990d-edf728d72f12',null,	'7ebd10ee-5018-4e11-9525-80ab5c6aebee',false)

*/

-- handle languagetype for value

if (func_workresultinstancevaluelanguagetypeuuid isNull)
	then templanguagetypeid = 20;
	else  templanguagetypeid = (select systagid from systag where systaguuid = func_workresultinstancevaluelanguagetypeuuid);
End if;

-- figure out the workresultid

if func_workresultuuid notNull
	then tempworkresultid = ARRAY(select workresultid from workresult
								where id = func_workresultuuid);
	else tempworkresultid = ARRAY(select workresultid from view_workresult
								where workresultname = func_workresultname
									and workresultworktemplateid in (select distinct workinstanceworktemplateid
																		from workinstance wi
																		where wi.id = any  (func_workinstanceuuidarray))
									and workresultisprimary = func_primaryaccuracy
									and languagetranslationtypeid = 20);
end if;


if (select distinct workresulttranslate from workresult where workresultid = any (tempworkresultid)) = false
	then
		return query
		select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lm.languagemastersource, lm.languagemasterid, func_workresultinstancevaluelanguagetypeuuid
		from workinstance wi
			inner join workresultinstance wri
				on wi.id = any (func_workinstanceuuidarray)
					and wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = any (tempworkresultid)
			inner join languagemaster lm
				on lm.languagemasterid = wri.workresultinstancevaluelanguagemasterid
		group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lm.languagemastersource, lm.languagemasterid;
	else
		return query
		select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lt.languagetranslationvalue, lt.languagetranslationmasterid as languagemasterid, func_workresultinstancevaluelanguagetypeuuid
		from workinstance wi
			inner join workresultinstance wri
				on wi.id = any (func_workinstanceuuidarray)
					and wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = any (tempworkresultid)
			inner join languagetranslations lt
				on lt.languagetranslationmasterid = wri.workresultinstancevaluelanguagemasterid
					and lt.languagetranslationtypeid = templanguagetypeid
		group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lt.languagetranslationvalue,lt.languagetranslationmasterid;
end if;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_readrtls(read_startdate timestamp with time zone, read_enddate timestamp with time zone, read_originationidarray bigint[], read_customeruuidarray text[], read_workinstanceuuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
 RETURNS TABLE(workinstanceid bigint, workinstanceuuid text, workinstancecustomerid bigint, workinstanceworktemplateid bigint, workinstancesiteid bigint, workinstancepreviousid bigint, workinstanceoriginatorworkinstanceid bigint, workinstancestartdate timestamp with time zone, workinstancecompleteddate timestamp with time zone, workinstanceexternalid text, workinstancetimezone text, locationid bigint, workerinstanceid bigint, workerinstanceuuid text, latitude numeric, longitude numeric, onlinestatus text, accuracy numeric, altitude numeric, altaccuracy numeric, heading numeric, speed numeric, previousworkinstanceexternalid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

tempworkerarray bigint[];
templocationarray bigint[];
tempcustomerarray text[];
tempworkinstance text[];
tempstardate timestamp with time zone;
tempenddate timestamp with time zone;

BEGIN

/*

-- future add in language type (For now hardoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_readrtls(null,null,null, null,null,null, null)

-- send in an array of customeruuids
select * from public.func_readrtls(null,null,null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,null, null)

-- send in an array of locationuuids
select * from public.func_readrtls(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_readrtls(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_readrtls('10/27/2024',null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_readrtls(null,'10/27/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_readrtls('10/27/2024','10/28/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in originationid
select * from public.func_readrtls(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in workinstances
select * from public.func_readrtls(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_readrtls(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- group by originationid
select wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone, min(wi.workinstancestartdate), max(wi.workinstancestartdate), count(*)
from public.func_readrtls(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18']) as wi
group by wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone

*/

if (read_customeruuidarray isNull or array_length(read_customeruuidarray, 1) = 0)
	then tempcustomerarray = ARRAY(
		select customeruuid
		from customerconfig
			inner join customer
				on customerconfigcustomeruuid = customeruuid
					and customerconfigvalue = 'true'
			inner join systag t
				on t.systaguuid = customerconfigtypeuuid
					and t.systagtype = 'RTLS'
			inner join systag category on t.systagparentid = category.systagid );
	else tempcustomerarray = read_customeruuidarray;
End if;

-- eventually move this to uuid or even entity

if (read_locationuuidarray isNull or array_length(read_locationuuidarray, 1) = 0)
	then templocationarray = ARRAY(
		select loc.locationid::text from location loc
		where loc.locationcustomerid in (select customerid from customer
									where customeruuid = any (tempcustomerarray))); -- replace this with a call to get all rtls locations for the customers
	else templocationarray = ARRAY(
		select lo2.locationid::text from location lo2
		where lo2.locationuuid = any (read_locationuuidarray));
End if;

if (read_workerinstanceuuidarray isNull or array_length(read_workerinstanceuuidarray, 1) = 0)
	then tempworkerarray = ARRAY(
		select worker_instance2.workerinstanceid from workerinstance worker_instance2
		where worker_instance2.workerinstancecustomerid in (select customerid from customer
										where customeruuid = any (tempcustomerarray)));
	else tempworkerarray = ARRAY(
		select worker_instance3.workerinstanceid from workerinstance worker_instance3
		where worker_instance3.workerinstanceuuid = any (read_workerinstanceuuidarray));
End if;

tempstardate =
	case
		when read_startdate isnull
			then '01/01/1900'
		else read_startdate
	end;

tempenddate =
	case
		when read_enddate isnull
			then clock_timestamp()
		else read_enddate
	end;

if (read_originationidarray isNull or array_length(read_originationidarray, 1) = 0)
		and (read_workinstanceuuidarray isNull or array_length(read_workinstanceuuidarray, 1) = 0)
	then tempworkinstance = Array
		(select id
			FROM workinstance wi
				join public.worktemplatetype wtt
					on wi.workinstanceworktemplateid = wtt.worktemplatetypeworktemplateid
						and worktemplatetypesystaguuid in ('f0d0bca1-827a-46da-80bc-af1c8ef914db')  -- RTLS
						and worktemplatetypecustomeruuid = any (tempcustomerarray)  -- Customer
						and wi.workinstancestatusid in (707,710)  -- in progress or Completed
						and wi.workinstancetrustreasoncodeid = 762  -- Trusted
						and wi.workinstancestartdate > tempstardate
						and wi.workinstancestartdate < tempenddate
						and wi.workinstancecompleteddate > tempstardate
						and wi.workinstancecompleteddate < tempenddate);
elseif(read_originationidarray isNull or array_length(read_originationidarray, 1) > 0)
	then tempworkinstance = ARRAY(select wi2.id
									from workinstance wi2
									where wi2.workinstanceoriginatorworkinstanceid = any(read_originationidarray));
end if;

return query
	select
		wi.workinstanceid,
		wi.id as workinstanceuuid,
		wi.workinstancecustomerid,
		wi.workinstanceworktemplateid,
		wi.workinstancesiteid,
		wi.workinstancepreviousid,
		wi.workinstanceoriginatorworkinstanceid,
		wi.workinstancestartdate,
		wi.workinstancecompleteddate,
		wi.workinstanceexternalid,
		wi.workinstancetimezone,
		wril.workresultinstancevalue::bigint as locationid,
		wriw.workresultinstancevalue::bigint as workerinstanceid,
		worker_instance.workerinstanceuuid,
		wrilat.workresultinstancevalue::numeric as latitude,
		wrilon.workresultinstancevalue::numeric as longitude,
		wrirtls.workresultinstancevalue::text as onlinestatus,
		wriaccuracy.workresultinstancevalue::numeric as accuracy,
		wrialtitude.workresultinstancevalue::numeric as altitude,
		wrialtitudeaccuracy.workresultinstancevalue::numeric as altaccuracy,
		wriheading.workresultinstancevalue::numeric as heading,
		wrispeed.workresultinstancevalue::numeric as speed,
		pwi.workinstanceexternalid
	FROM workinstance wi
		JOIN (select *   -- get primary location
				from public.func_read_workresultinstancevalues_bigint(tempworkinstance, null,'Location',true )) wril
			ON wi.workinstanceid = wril.workresultinstanceworkinstanceid
				and wril.workresultinstancevalue = any (templocationarray)
		LEFT JOIN (select *   -- get primary worker
				from public.func_read_workresultinstancevalues_bigint(tempworkinstance,null,'Worker',true )) wriw
			ON wi.workinstanceid = wriw.workresultinstanceworkinstanceid
				and wriw.workresultinstancevalue = any (tempworkerarray)
		inner join (select *   -- get latitude
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Latitude',false )) wrilat
			ON wi.workinstanceid = wrilat.workresultinstanceworkinstanceid
		inner join (select *   -- get longitude
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Longitude',false )) wrilon
			ON wi.workinstanceid = wrilon.workresultinstanceworkinstanceid
		inner join (select *
						from public.func_read_workresultinstancevalues_text(tempworkinstance, null,
								'RTLS - Online Status', '7ebd10ee-5018-4e11-9525-80ab5c6aebee',false)) wrirtls
			ON wi.workinstanceid = wrirtls.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsaccuracy
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Accuracy',false )) wriaccuracy
			ON wi.workinstanceid = wriaccuracy.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsaltitude
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Altitude',false )) wrialtitude
			ON wi.workinstanceid = wrialtitude.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsaltitudeaccuracy
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Altitude Accuracy',false )) wrialtitudeaccuracy
			ON wi.workinstanceid = wrialtitudeaccuracy.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsheading
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Heading',false )) wriheading
			ON wi.workinstanceid = wriheading.workresultinstanceworkinstanceid
		inner join (select *   -- get rtlsspeed
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Speed',false )) wrispeed
			ON wi.workinstanceid = wrispeed.workresultinstanceworkinstanceid
        left join workinstance pwi
            ON pwi.workinstanceid = wi.workinstancepreviousid
		inner join workerinstance worker_instance
			ON worker_instance.workerinstanceid = wriw.workresultinstancevalue
	where wriw.workresultinstancevalue = any (tempworkerarray)
	order by wi.workinstanceid
	;

End;
$function$;


REVOKE ALL ON FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: func_timesheet_override_bigint(bigint,date); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_timesheet_override_bigint(temcustomerid bigint, tempdate date)
 RETURNS TABLE(workresultinstancevalue bigint, workresultinstanceworkinstanceid bigint)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	tempworkresultid bigint[];
BEGIN

-- this probably could be converted to the dw generic script.  But, for now we will just hard code this.
-- tempdate = '2025-01-10'

return query
select owri.workresultinstancevalue::bigint, owri.workresultinstanceworkinstanceid
		from workinstance wi
			inner join workresultinstance owri
				on owri.workresultinstanceworkinstanceid =  wi.workinstanceid
					and wi.workinstancestartdatetz::date > tempdate - ('14 days')::interval
					-- and wi.workinstancestartdatetz::date <= tempdate
					and wi.workinstancecustomerid = temcustomerid
			inner join datawarehouse.dim_workresult_v2 owr
				on owr.dim_workresultid = owri.workresultinstanceworkresultid
					and owr.dim_workresultname = 'Start Override'
					and owr.dim_workresultisprimary = false
					and owri.workresultinstanceworkinstanceid =  wi.workinstanceid;

/*
create temp table tempwri
as
select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue
from workinstance wi
	inner join workresultinstance wri
		on wi.id = any (func_workinstanceuuidarray)
			and wri.workresultinstanceworkinstanceid = wi.workinstanceid
			and wri.workresultinstanceworkresultid = any (tempworkresultid)
group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue;

return query
	select pl.workresultinstancecustomerid, pl.workresultinstanceworkinstanceid, pl.workresultinstancevalue::bigint
			from tempwri pl;

drop table tempwri;*/

End;

$function$;


REVOKE ALL ON FUNCTION func_timesheet_override_bigint(bigint,date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_timesheet_override_bigint(bigint,date) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_timesheet_override_bigint(bigint,date) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: superset_timesheet_missingclockin(text,integer,date); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.superset_timesheet_missingclockin(read_customeruuid text, read_days integer, reference_day date)
 RETURNS TABLE(workerinstanceid bigint, workerusername text, workerfullname text, workerfirstname text, workerlastname text, workerinstancescanid text, workerinstancestartdate timestamp with time zone, workerinstanceenddate timestamp with time zone, workerinstancecountit boolean, workerinstancetendreluser boolean, workerlastclockin date, sitename text, customer text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
    tempcustomerid bigint;
    temptimezone   text;
    tempdate       date;
	temptimestamp timestamp with time zone;

BEGIN

    tempcustomerid = (select cu.customerid
                      from public.customer cu
                      where read_customeruuid = cu.customeruuid);

    temptimezone = (select distinct dim_sitetimezone
                    from datawarehouse.fact_timesheet ts
                             inner join datawarehouse.dim_site_v2 site
                                        on site.dim_dimsiteid = ts.dim_dimsiteid
                    where fact_customerid = tempcustomerid
                      and fact_workinstancedisplaystartdate > now() - ('14 days')::interval);

    tempdate = case
                   when reference_day notNull
                       then reference_day
                   else (now() AT TIME ZONE temptimezone)::date
        end;

	temptimestamp = case
                   when reference_day notNull
                       then reference_day
                   else (now() AT TIME ZONE temptimezone)
       	 end;

    return query select worker.dim_workerinstanceid                         AS workerinstanceid,
                        worker.dim_workerusername                           AS workerusername,
                        worker.dim_workerfullname                           AS workerfullname,
                        worker.dim_workerfirstname                          AS workerfirstname,
                        worker.dim_workerlastname                           AS workerlastname,
                        worker.dim_workerinstancescanid                     AS workerinstancescanid,
                        worker.dim_workerinstancestartdate                  AS workerinstancestartdate,
                        worker.dim_workerinstanceenddate                    AS workerinstanceenddate,
                        worker.dim_workerinstancecountit                    AS workerinstancecountit,
                        worker.dim_workerinstancetendreluser                AS workerinstancetendreluser,
                        lastworkers.fact_workinstancedisplaystartdate ::Date as workerlastclockin,
                        lastworkers.dim_sitename                            as sitename,
                        lastworkers.dim_customername                        as customer
                 from ( select
							fact_workerinstanceid,
							dim_sitename,
							dim_sitetimezone,
							dim_customername,
							max(fact_workinstancedisplaystartdate) as fact_workinstancedisplaystartdate
						from
							(select wri.workresultinstancevalue as fact_workerinstanceid,
								   dim_sitename,
								   dim_sitetimezone,
								   dim_customername,
								   case when foo.workresultinstancevalue isNull
								   			then (workinstancestartdatetz)
										else (TO_TIMESTAMP(foo.workresultinstancevalue / 1000) AT TIME ZONE owi.workinstancetimezone)
									End as fact_workinstancedisplaystartdate
							from workinstance AS owi
		                       INNER JOIN worktemplatetype wtt
                                  ON owi.workinstanceworktemplateid = wtt.worktemplatetypeworktemplateid
                                      AND wtt.worktemplatetypesystagid IN (883, 884)
										and owi.workinstancecustomerid = tempcustomerid
										and owi.workinstancestartdatetz::date > tempdate - ('14 days')::interval
										-- and owi.workinstancestartdatetz::date <= tempdate
										and owi.workinstancestatusid in (707, 710)
								 inner join datawarehouse.dim_site_v2 site
									on site.dim_siteid = owi.workinstancesiteid
								 inner join datawarehouse.dim_customer_v2 cust
									on cust.dim_customerid = owi.workinstancecustomerid
								 inner join workresultinstance wri
									on owi.workinstanceid = wri.workresultinstanceworkinstanceid
								inner join datawarehouse.dim_workresult_v2 wr
									on wr.dim_workresultid = wri.workresultinstanceworkresultid
										and dim_workresultname = 'Worker'
										and dim_workresultisprimary = false
								left join (select * from datawarehouse.func_timesheet_override_bigint(tempcustomerid,tempdate)) as foo
										on foo.workresultinstanceworkinstanceid =  owi.workinstanceid) as foofoo
							group by foofoo.fact_workerinstanceid, dim_sitename, dim_sitetimezone, dim_customername
								)  as lastworkers
					inner join datawarehouse.dim_worker_v2 worker
							 on lastworkers.fact_workerinstanceid::bigint = worker.dim_workerinstanceid
								 and (dim_workerinstanceenddate isNull
									 or dim_workerinstanceenddate  >= temptimestamp )
				where fact_workinstancedisplaystartdate::date <> tempdate;


End;

$function$;


REVOKE ALL ON FUNCTION superset_timesheet_missingclockin(text,integer,date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION superset_timesheet_missingclockin(text,integer,date) TO PUBLIC;
GRANT EXECUTE ON FUNCTION superset_timesheet_missingclockin(text,integer,date) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_customer_config_create_v2(text,text,text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_config_create_v2(IN customer_uuid text, IN site_uuid text, IN config_uuid text, IN value_type_uuid text, IN config_value text, IN modified_by text, OUT config_id text)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerconfigvalue text;
BEGIN
	/*  MJK 20240510 
		Added in Exception - Customer Config already exists
		Added in Exception - Not a valid Category and Config combination
		Added in handling if the config_value comes in Null.  We wil use the default value
	*/

	
    -- Check if customer exists
    PERFORM * FROM public.customer WHERE customeruuid = customer_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    -- Check if customer config already exists
    PERFORM * FROM public.customerconfig 
		WHERE customerconfigcustomeruuid = customer_uuid
			and customerconfigsiteuuid = site_uuid
			and customerconfigtypeuuid = config_uuid
			and customerconfigvaluetypeuuid = value_type_uuid;
    IF FOUND THEN
        RAISE EXCEPTION 'Customer Config already exists';
    END IF;

	-- check if the category and config are a legit combo
    PERFORM * FROM public.customerconfig 
		WHERE customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0 and customersiteid isNull)
			and customerconfigsiteuuid = site_uuid
			and customerconfigtypeuuid = config_uuid
			and customerconfigvaluetypeuuid = value_type_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Not a valid Category and Config combination';
    END IF;	

	-- get the default value and decide if we want to use it.  We currentl use it if the value passed in is null
	-- Future:  We could make this stronger to check if the value passed in is even valid.  

	if customerconfigvalue isNull
		then 
			tempcustomerconfigvalue = (select customerconfigvalue 
										FROM public.customerconfig 
										WHERE customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0 and customersiteid isNull)
											and customerconfigsiteuuid = site_uuid
											and customerconfigtypeuuid = config_uuid
											and customerconfigvaluetypeuuid = value_type_uuid
											limit 1);
		else tempcustomerconfigvalue = customerconfigvalue;
	end if;

	 -- Insert new customer config and return the newly generated UUID
    INSERT INTO public.customerconfig (customerconfigcustomeruuid, 
										customerconfigsiteuuid,
										customerconfigtypeuuid,
										customerconfigvaluetypeuuid, 
										customerconfigvalue,
                                       customerconfigmodifiedby)
    VALUES (customer_uuid, 
			site_uuid, 
			config_uuid, 
			value_type_uuid, 
			tempcustomerconfigvalue, 
			modified_by)
    RETURNING customerconfiguuid INTO config_id;

END;
$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_customer_config_list_v2(text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_customer_config_list_v2(customer_uuid_param text, site_id_param bigint, language_id bigint)
 RETURNS TABLE(uuid text, started_at timestamp without time zone, ended_at timestamp without time zone, updated_by_uuid text, type_uuid text, type text, value text, value_type text)
 LANGUAGE plpgsql
AS $function$
Declare
	templanguageid bigint;
BEGIN
/* MJK 20240510
	
	Added in a default language of engliesh if Null is accidentally passed in for type.  
	Flipped this to plpgsql so that we can have temp variables.  
	Explicitely returned the query.
	Addeed in site.  If Null get all otherwise get the configs for a site.  
	Check if the customer exists.  

	Future:  Twait to add - Category and category id.  
	Future: Add in site id for the call.
	Future: Might want to switch this to use languagetypeuuid instead.   
	Future: Might change this to default to the language for the customer name.
	Future: Might want to create a default langaugage customer config.
*/
	-- set language to english if nothing is set in.  
	
	if language_id isNull
		then
			templanguageid = 20;
		else
			templanguageid = language_id;
	end if;

    -- Check if customer exists
    PERFORM * FROM public.customer WHERE customeruuid = customer_uuid_param;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;


	if site_id_param notNull
		then
		    -- Check if site exists
		    PERFORM * FROM public.location WHERE locationid = site_id_param;
		    IF NOT FOUND THEN
		        RAISE EXCEPTION 'Site does not exist';
		    END IF;
		
		    -- Check if site is valid for customer 
		
			PERFORM * FROM public.location 
						inner join customer
							on locationcustomerid = locationcustomerid
						WHERE locationid = site_id_param;
			IF NOT FOUND THEN
				RAISE EXCEPTION 'Not a valid Customer and Site combination';
			END IF;
	End If;

	
RETURN QUERY SELECT customerconfiguuid       as uuid,
       customerconfigstartdate  as started_at,
       customerconfigenddate    as ended_at,
       customerconfigmodifiedby as updated_by_uuid,
       customerconfigtypeuuid   as type_uuid,
       vs.systagname            as type,
       customerconfigvalue      as value,
       value_type.systagtype    as value_type
FROM public.customerconfig cc
         INNER JOIN public.view_systag vs
                    ON cc.customerconfigtypeuuid = vs.systaguuid 
						and vs.languagetranslationtypeid = templanguageid
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
WHERE customerconfigcustomeruuid = customer_uuid_param;

END;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_customer_config_templates_list_v2(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_customer_config_templates_list_v2(language_id bigint)
 RETURNS TABLE(uuid text, type_uuid text, type text, value text, value_type text)
 LANGUAGE plpgsql
AS $function$

Declare
	templanguageid bigint;
BEGIN
	
/* MJK 20240510
	
	Added in a default language of engliesh if Null is accidentally passed in for type.  
	Flipped this to plpgsql so that we can have temp variables.  
	Explicitely returned the query.
	
	Future: Might want to switch this to use languagetypeuuid instead.   

*/

if language_id isNull
	then
		templanguageid = 20;
	else
		templanguageid = language_id;
end if;

RETURN QUERY SELECT customerconfiguuid     as uuid,
       customerconfigtypeuuid as type_uuid,
       vs.systagname          as type,
       customerconfigvalue    as value,
       value_type.systagtype  as value_type
FROM public.customerconfig cc
         INNER JOIN public.view_systag vs
                    ON cc.customerconfigtypeuuid = vs.systaguuid and vs.languagetranslationtypeid = templanguageid
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
WHERE customerconfigsiteuuid is null
  and customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0);

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_customer_config_templates_list_v2(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_templates_list_v2(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_templates_list_v2(bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_customer_delete_v2(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_delete_v2(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

/* MJK 20240510
	
	Added in a customer check.  

*/  PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;
	
-- set the customer as modified

update customer
set customerenddate = clock_timestamp() - interval '1 day',
	customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_customer_read_v2(text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_customer_read_v2(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text)
 RETURNS TABLE(customerid bigint, customernamelanguagemasterid bigint, customername text, customerlanguagetypeid bigint, customerlanguagetypeuuid text, customerlanguagetypename text, customerstartdate timestamp with time zone, customerenddate timestamp with time zone, customerexternalid text, customerexternalsystemid bigint, customerexternalsystemuuid text, customerexternalsystemname text, customercreateddate timestamp with time zone, customermodifieddate timestamp with time zone, customermodifiedby bigint)
 LANGUAGE sql
AS $function$

/* MJK 20240510
	
	Added in comments only 

	Future:  flip to plpgsql 
	Future: Might want to switch this to use languagetypeuuid.   
	Future: Add in default language if we add language.
	Future: Might want to create a default langaugage customer config.
*/

-- Example to call function

SELECT 
	customerid, 
	customernamelanguagemasterid, 
	customername, 
	customerlanguagetypeid,
	customerlanguagetypeuuid,
	lt.systagtype as customerlanguagetypename,
	customerstartdate, 
	customerenddate, 
	customerexternalid, 
	customerexternalsystemid,
	customerexternalsystemuuid,
	sn.systagtype as  customerexternalsystemname, 
	customercreateddate, 
	customermodifieddate, 
	customermodifiedby
FROM public.customer c
	inner join systag lt
		on customerlanguagetypeuuid = lt.systaguuid
	left join systag sn
		on customerexternalsystemuuid = sn.systaguuid
where (read_customeruuid = customeruuid 
		or (read_customerexternalid = customerexternalid
		and read_customerexternalsystemuuid = customerexternalsystemuuid));

$function$;


REVOKE ALL ON FUNCTION zzz_crud_customer_read_v2(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_read_v2(text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_read_v2(text,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_customer_restart_v2(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_restart_v2(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

/* MJK 20240510
	
	Added in a customer check.  

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;
	

update customer
set customerenddate = null,
	customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_restart_v2(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_restart_v2(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_restart_v2(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_customer_update_v2(text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_update_v2(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_customername text, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	templanguagetypeid bigint;
	tempcustomerexternalsystemid bigint;
Begin


/* MJK 20240510
	
	Added in a customer check.  

	Future: update external systems.
*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	
	if language_id isNull
		then
			templanguagetypeid = 20;
		else
			templanguagetypeid = (select systagid 
					  			from systag
					 			 where systaguuid = update_languagetypeuuid);
	end if;

tempcustomerexternalsystemid = (select systagid 
								  from systag
								  where systaguuid = update_customerexternalsystemuuid);

update_customeruuid = (select customeruuid 
								  from customer
								  where (update_customeruuid = customeruuid 
									or (update_customerexternalid = customerexternalid
									and update_customerexternalsystemuuid = customerexternalsystemuuid)));

if (update_customername notNull and update_customername <> '')
	then 
		update languagemaster
		set languagemastersource = update_customername,
			languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
			languagemastermodifiedby = update_modifiedbyid,
			languagemastermodifieddate = clock_timestamp()
		from customer
		where (update_customeruuid = customeruuid 
				or (update_customerexternalid = customerexternalid
				and update_customerexternalsystemuuid = customerexternalsystemuuid))
			and customernamelanguagemasterid = languagemasterid
			and customername <> update_customername;
		
		update customer
		set customername = update_customername
		where (update_customeruuid = customeruuid 
				or (update_customerexternalid = customerexternalid
				and update_customerexternalsystemuuid = customerexternalsystemuuid))
			and customername <> update_customername;
end if;

-- Set language type id for the customer
-- We could harden this to check to see if the languagetype id is valid 
-- For now I will assume it is ok

update customer
set customerlanguagetypeid = templanguagetypeid,
	customerlanguagetypeuuid = update_languagetypeuuid	
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid))
	and update_languagetypeuuid notNull
	and customerlanguagetypeuuid <> update_languagetypeuuid;

-- set the customer as modified

update customer
set customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_update_v2(text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_location_delete_v2(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_location_delete_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_locationid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
	Future:  Add in a site check
	Future:  Cascade changes

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_locationid
										and locationcustomerid = tempcustomerid
										and locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Location does not exist';
    END IF;

	
update location
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_locationid 
	and locationistop = false
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_location_delete_v2(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_location_delete_v2(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_location_delete_v2(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_location_read_v2(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_location_read_v2(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_locationid bigint, read_languagetypeuuid text)
 RETURNS TABLE(locationid bigint, locationcustomerid bigint, locationcategoryid bigint, locationcategory text, locationlanguagetypeid bigint, locationlanguagetypename text, locationnameid bigint, locationfullname text, locationscanid text, locationlookupname text, locationtimezone text, locationsiteid bigint, locationsitename text, locationparentid bigint, locationparentname text, locationiscornerstone boolean, locationcornerstoneid bigint, locationcornerstonename text, locationcornerstoneorder bigint, locationstartdate timestamp with time zone, locationenddate timestamp with time zone, locationexternalsystemid bigint, locationexternalid text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	templanguagetypeid bigint;

Begin

/* MJK 20240510
	
	Added in a default language of english if Null is accidentally passed in for type.  
	Added exceptions around checks for customer and site.

*/

	-- Check if customer exists
    PERFORM * FROM public.customer 
				WHERE (read_customeruuid = customeruuid 
					or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	-- Check if location exists
    PERFORM * FROM public.location loc
					inner join customer
						on customerid = loc.locationcustomerid		
				WHERE loc.locationid = read_locationid
					and loc.locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'location does not exist';
    END IF;

	tempcustomerid = (select customerid 
						from customer 
						where (read_customeruuid = customeruuid 
							or (read_customerexternalid = customerexternalid
							and read_customerexternalsystemuuid = customerexternalsystemuuid))); 

	templanguagetypeid = (select systagid 
						  from systag
						  where systaguuid = read_languagetypeuuid);
	
	if templanguagetypeid isNull
		then templanguagetypeid = 20;
	end if;

RETURN QUERY SELECT 
	loc.locationid, 
	loc.locationcustomerid, 
	cat.custagid as locationcategoryid,
	cat.custagtype as locationcategory,
	lan.systagid as locationlanguagetypeid,
	lan.systagtype as locationlanguagetypename, 
	loc.locationnameid, 
	loc.locationfullname,  
	loc.locationscanid,
	loc.locationlookupname,
	loc.locationtimezone,
	loc.locationsiteid,	
	site.locationfullname as locationsitename,
	loc.locationparentid,	
	parent.locationfullname as locationparentname,	
	loc.locationiscornerstone, 
	loc.locationcornerstoneid,
	corner.locationfullname as locationcornerstonename,  -- join this in
	loc.locationcornerstoneorder, 
	loc.locationstartdate, 
	loc.locationenddate, 
	loc.locationexternalsystemid, 
	loc.locationexternalid
FROM public.view_location loc
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join view_location site
		on site.locationid = loc.locationsiteid
			and site.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join view_location parent
		on parent.locationid = loc.locationparentid
			and parent.languagetranslationtypeid = loc.languagetranslationtypeid
	left join view_location corner
		on corner.locationid = loc.locationcornerstoneid
			and corner.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join custag cat
		on cat.custagid = loc.locationcategoryid
where loc.locationid = read_locationid
	and loc.locationistop = false
	and loc.locationcustomerid = tempcustomerid
	and loc.languagetranslationtypeid = templanguagetypeid;

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_location_read_v2(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_location_restart_v2(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_location_restart_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_locationid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
	Future:  Add in a site check
	Future:  Cascade changes

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_locationid
										and locationcustomerid = tempcustomerid
										and locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Location does not exist';
    END IF;

	
	
update location
set locationenddate = null,
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_locationid 
	and locationistop = false
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_location_restart_v2(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_location_restart_v2(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_location_restart_v2(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_location_update_v2(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_location_update_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_siteid bigint, IN update_parentid bigint, INOUT update_locationid bigint, IN update_locationexternalid text, IN update_locationexternalsystemuuid text, IN update_locationfullname text, IN update_locationlookupname text, IN update_locationscanid text, IN update_locationiscornerstone boolean, IN update_locationcornerstoneid bigint, IN update_locationcornerstoneorder bigint, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsiteid bigint;
	tempparentid bigint;
	templocationid bigint;	
	updatelocationexternalid text;
	updatelocationexternalsystemid bigint;
	templocationfullname text;
	updatelocationlookupname text;	
	updatelocationscanid text;	
	updatelocationiscornerstone boolean;		
	updatelocationcornerstoneid bigint;
	updatelocationcornerstoneorder bigint;
	updatelocationtimezone text;	
	templanguagetypeid bigint;
	templocationlanguagetypeid bigint;
	updatelocationmodifieddate  timestamp with time zone;
Begin


/* MJK 20240513
	
-- We only allow the name,lookupname, scanid, and languagetype to change
-- we won't update external systems with this change.  Possibly a future enhancement.

	
	Added in a customer check.  
	Added a location check.

	Future: update external systems.
	Future:  cascade changes
*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomeruuid = (select customeruuid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_locatonid
										and locationsiteid = update_siteid
										and locationcustomerid = tempcustomerid
										and locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Location does not exist';
    END IF;


	
if update_languagetypeuuid isNull
	then 
		templanguagetypeid =  20;
	else 
		templanguagetypeid = (select systagid from systag where systaguuid = update_languagetypeuuid);
end if;



CREATE TEMP TABLE templocation AS
select 
	locationid as templocationid,
	locationsiteid as  tempsiteid,
	locationparentid as  tempparentid,	
   	locationnameid as templanguagemasterid,
	locationexternalid as templocationexternalid,
	locationexternalsystemid as templocationexternalsystemid,
	locationfullname as templocationfullname,
	locationlookupname as templocationlookupname,
	locationscanid as templocationscanid,
	locationiscornerstone as templocationiscornerstone,	
	locationcornerstoneid as templocationcornerstoneid,
	locationcornerstoneorder as templocationcornerstoneorder,
	locationtimezone as templocationtimezone	
from view_location
where languagetranslationtypeid = templanguagetypeid
	and locationcustomerid = tempcustomerid
	and locationid = update_locationid;

-- If the name changed then we update the name in the languagemaster and in the customer tables

update languagemaster
set languagemastersource = update_locationfullname,
	languagemastersourcelanguagetypeid = templanguagetypeid,
	languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
	languagemastermodifiedby = update_modifiedbyid,
	languagemastermodifieddate = clock_timestamp()
from location
where locationid = update_locationid
	and locationnameid = languagemasterid;

if update_locationexternalid isNull  
	then
		updatelocationexternalid = (select templocationexternalid from templocation);
	else
		updatelocationexternalid = update_locationexternalid;
end if;

if update_locationexternalsystemuuid isNull  
	then
		updatelocationexternalsystemid = (select templocationexternalsystemid from templocation);
	else
		updatelocationexternalsystemid = update_locationexternalid;
end if;

if update_locationlookupname isNull 
	then
		updatelocationlookupname = (select templocationlookupname from templocation);
	else	
		updatelocationlookupname = update_locationlookupname;
end if;

if update_locationscanid isNull 
	then
		updatelocationscanid = (select templocationscanid from templocation); 
	Else
		updatelocationscanid = update_locationscanid;
end if;

if update_locationiscornerstone = true or update_locationcornerstoneid isnull
	then
		updatelocationcornerstoneid = update_locationid;
		updatelocationiscornerstone = true;
		updatelocationcornerstoneorder = 1;
		updatelocationmodifieddate = clock_timestamp();
	else
		updatelocationcornerstoneid = create_locationcornerstoneid;
		updatelocationiscornerstone = false;
		updatelocationcornerstoneorder = create_locationcornerstoneorder;
		updatelocationmodifieddate = clock_timestamp();
End if;

update location
	set locationexternalid = updatelocationexternalid,
	locationexternalsystemid = updatelocationexternalsystemid,
	locationlookupname = updatelocationlookupname,
	locationscanid = updatelocationscanid,
	locationiscornerstone = updatelocationiscornerstone,
	locationcornerstoneid = updatelocationcornerstoneid,
	locationcornerstoneorder = updatelocationcornerstoneorder,
	locationmodifieddate = updatelocationmodifieddate,
	locationmodifiedby = update_modifiedbyid
where locationid = update_locationid
	and locationcustomerid = tempcustomerid;

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_location_update_v2(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_location_update_v2(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_location_update_v2(text,text,text,bigint,bigint,bigint,text,text,text,text,text,boolean,bigint,bigint,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_site_delete_v2(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_site_delete_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
	Future:  Cascade changes

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_siteid
										and locationcustomerid = tempcustomerid
										and locationistop = true;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Site does not exist';
    END IF;

	
update location
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_siteid 
	and locationistop = true
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_site_read_v2(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_site_read_v2(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_siteid bigint, read_languagetypeuuid text)
 RETURNS TABLE(locationid bigint, locationcustomerid bigint, locationcategoryid bigint, locationcategory text, locationlanguagetypeid bigint, locationlanguagetypename text, locationnameid bigint, locationfullname text, locationscanid text, locationlookupname text, locationtimezone text, locationsiteid bigint, locationsitename text, locationparentid bigint, locationparentname text, locationiscornerstone boolean, locationcornerstoneid bigint, locationcornerstonename text, locationcornerstoneorder bigint, locationstartdate timestamp with time zone, locationenddate timestamp with time zone, locationexternalsystemid bigint, locationexternalid text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	tempsiteid bigint;
	templanguagetypeid bigint;
	templocationexternalsystemid bigint;

Begin
	
/* MJK 20240510
	
	Added in a default language of english if Null is accidentally passed in for type.  
	Added exceptions around checks for customer and site.

*/

	-- Check if customer exists
    PERFORM * FROM public.customer 
				WHERE (read_customeruuid = customeruuid 
					or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	-- Check if site exists
    PERFORM * FROM public.location loc
					inner join customer
						on customerid = loc.locationcustomerid		
				WHERE loc.locationid = read_siteid
					and loc.locationistop = true;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Site does not exist';
    END IF;

-- get the languagetypeid 
	tempcustomerid = (select customerid 
						from customer 
						where (read_customeruuid = customeruuid 
							or (read_customerexternalid = customerexternalid
							and read_customerexternalsystemuuid = customerexternalsystemuuid))); 

	templanguagetypeid = (select systagid 
						  from systag
						  where systaguuid = read_languagetypeuuid);
	
	if templanguagetypeid isNull
		then templanguagetypeid = 20;
	end if;

-- get the site

RETURN QUERY SELECT 
	loc.locationid, 
	loc.locationcustomerid, 
	cat.custagid as locationcategoryid,
	cat.custagtype as locationcategory,
	lan.systagid as locationlanguagetypeid,
	lan.systagtype as locationlanguagetypename, 
	loc.locationnameid, 
	loc.locationfullname,  
	loc.locationscanid,
	loc.locationlookupname,
	loc.locationtimezone,
	loc.locationsiteid,	
	site.locationfullname as locationsitename,
	loc.locationparentid,	
	parent.locationfullname as locationparentname,	
	loc.locationiscornerstone, 
	loc.locationcornerstoneid,
	corner.locationfullname as locationcornerstonename,  -- join this in
	loc.locationcornerstoneorder, 
	loc.locationstartdate, 
	loc.locationenddate, 
	loc.locationexternalsystemid, 
	loc.locationexternalid
FROM public.view_location loc
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join view_location site
		on site.locationid = loc.locationsiteid
			and site.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join view_location parent
		on parent.locationid = loc.locationparentid
			and parent.languagetranslationtypeid = loc.languagetranslationtypeid
	left join view_location corner
		on corner.locationid = loc.locationcornerstoneid
			and corner.languagetranslationtypeid = loc.languagetranslationtypeid
	inner join custag cat
		on cat.custagid = loc.locationcategoryid
where loc.locationid = read_siteid
	and loc.locationistop = true
	and loc.locationcustomerid = tempcustomerid
	and loc.languagetranslationtypeid = templanguagetypeid;

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_site_read_v2(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_site_read_v2(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_site_read_v2(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_site_restart_v2(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_site_restart_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
	Future:  Cascade changes

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_siteid
										and locationcustomerid = tempcustomerid
										and locationistop = true;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Site does not exist';
    END IF;
	

update location
set locationenddate = null,
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where locationid = update_siteid 
		and locationistop = true
		and locationcustomerid = tempcustomerid;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_site_restart_v2(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_restart_v2(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_restart_v2(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_site_update_v2(text,text,text,bigint,text,text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_site_update_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_siteexternaluuid text, IN create_siteexternalsystemuuid text, IN update_sitefullname text, IN update_sitelookupname text, IN update_sitescanid text, IN update_sitetimezone text, IN update_languagetypeuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempsiteexternalid text;
	templanguagetypeid bigint;
	templocationlanguagetypeid bigint;	
	updatesitelookupname text;
	updatesitescanid text;
	updatesitetimezone text;
Begin

/* MJK 20240513
	
-- We only allow the name,lookupname, scanid, and languagetype to change
-- we won't update external systems with this change.  Possibly a future enhancement.

	
	Added in a customer check.  
	Added a location check.

	Future: update external systems.
	Future:  cascade changes
*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomeruuid = (select customeruuid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_siteid
										and locationsiteid = update_siteid
										and locationcustomerid = tempcustomerid
										and locationistop = true;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Site does not exist';
    END IF;

if update_languagetypeuuid isNull
	then 
		templanguagetypeid =  20;
	else 
		templanguagetypeid = (select systagid from systag where systaguuid = update_languagetypeuuid);
end if;

-- update customer id

CREATE TEMP TABLE tempsite
	(tempsiteid bigint,
   	templanguagemasterid bigint,
	tempsitefullname text,
	tempsitelookupname text,
	tempsitescanid text,
	tempsitetimezone text);

insert into tempsite (
	tempsiteid,
   	templanguagemasterid,
	tempsitefullname,
	tempsitelookupname,
	tempsitescanid,
	tempsitetimezone	
)
select 
	locationid as tempsiteid,
   	locationnameid as templanguagemasterid,
	locationfullname as tempsitefullname,
	locationlookupname as tempsitelookupname,
	locationscanid as tempsitescanid,
	locationtimezone as tempsitetimezone	
from view_location
where languagetranslationtypeid = templanguagetypeid
	and locationcustomerid = tempcustomerid
	and locationid = update_siteid;

-- If the name changed then we update the name in the languagemaster and in the customer tables

if update_sitelookupname isNull
	then
		updatesitelookupname = (select tempsitelookupname from tempsite);
	else
		updatesitelookupname = update_sitelookupname;
end if;

if update_sitescanid isNull
	then
		updatesitescanid = (select tempsitescanid from tempsite);
	else
		updatesitescanid = update_sitescanid;
end if;

if update_sitetimezone isNull
	then
		updatesitetimezone = (select tempsitetimezone from tempsite);
	else
		updatesitetimezone = update_sitetimezone;	
end if;

update languagemaster
set languagemastersource = update_sitefullname,
	languagemastersourcelanguagetypeid = templanguagetypeid,
	languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION',
	languagemastermodifiedby = update_modifiedbyid,
	languagemastermodifieddate = clock_timestamp()
from tempsite
where tempsiteid = update_siteid
	and templanguagemasterid = languagemasterid
	and tempsitefullname <> update_sitefullname;

update location
	set locationlookupname = updatesitelookupname,
	locationscanid = updatesitescanid,
	locationtimezone = updatesitetimezone
where locationid = update_siteid
	and locationcustomerid = tempcustomerid;

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_site_update_v2(text,text,text,bigint,text,text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_update_v2(text,text,text,bigint,text,text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_update_v2(text,text,text,bigint,text,text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: PROCEDURE ; Name: zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_timesheet_create_customer(IN create_customername text, OUT create_customeruuid text, IN create_customerbillingid text, IN create_customerbillingsystemid text, INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid text, OUT create_adminuuid text, OUT create_sitename text, IN create_timezone text, IN create_languagetypeuuid text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Custoemr temp values
	tempcustomerid bigint;
	tempbillingsystemid bigint;
-- Worker Temp Values
	tempidentitysystemid text;
	tempworkeridentitysystemid bigint; 
	tempusername text;
	tempworkeruuid text;
-- Site/Location temp valules
	tempcustagsitetypeid bigint;
	tempsiteid bigint;
	tempsitelanguagemasterid bigint; 
	tempcustagentrytypeid bigint;
	tempcustagentrytypeuuid text;
	tempentryid bigint;
	tempcustagbreaktypeid bigint;
	tempcustagbreaktypeuuid text;
	tempbreakid bigint;
-- template, instance and result
	tempworktemplateid bigint;
	tempworktemplateuuid text;
	tempworkfrequencyid bigint;
	tempworkresultid bigint;
	tempworkinstanceid bigint;
-- General temp values
	templanguagemasterid bigint;
	templocationtimezone text;
	templanguagetypeidid  bigint;

Begin

-- create the initial customer
-- ideally this can be CRUD for customer, but here I am just hardcoding it

create_customeruuid = ( select customeruuid 
						from view_customer cust
						where cust.customername = create_customername
							and cust.languagetranslationtypeid = 20);

-- If the customer already exists we return.  Should we send an error?  At this point we will just return.  

if create_customeruuid notNull
	then
		return;
End if;

-- Need to check for admin check early as well

if (create_adminemailaddress isNull and create_adminphonenumber isNull)
	then
		return;
End if;

if (create_adminidentityid isNull)
	then
		return;
End if;

tempbillingsystemid = (select systagid 
					  from systag
					  where systaguuid = create_customerbillingsystemid);

templanguagetypeidid = (select systagid 
					  from systag
					  where systaguuid = create_languagetypeuuid);

-- Insert the customer and get back the customeruuid.  

INSERT INTO public.customer(
	customername,
	customerstartdate,
	customerlanguagetypeid,
	customerlanguagetypeuuid,
	customernamelanguagemasterid,
	customerexternalid,	
	customerexternalsystemid,
	customerexternalsystemuuid,
	customermodifiedby
)
VALUES ( create_customername, 
		clock_timestamp(), 
		templanguagetypeidid, 
		create_languagetypeuuid,
		4367,	
		create_customerbillingid, 
		tempbillingsystemid, 
		create_customerbillingsystemid,
		create_modifiedby)
Returning customeruuid,customerid into create_customeruuid,tempcustomerid;   
-- Not sure if the above is allowed.  2 variables into 2 valiables

-- add customer name into languagemaster

INSERT INTO public.languagemaster(
	languagemastercustomerid, 
	languagemastersourcelanguagetypeid, 
	languagemastersource, 
	languagemastermodifiedby)
	VALUES (tempcustomerid,templanguagetypeidid,create_customername,create_modifiedby)
	Returning languagemasterid into templanguagemasterid;

-- Fix the Language Master iDs

update public.customer
set customernamelanguagemasterid = templanguagemasterid
where customerid = tempcustomerid;

-- Add the languagetype to customer reqeusted languages

insert into customerrequestedlanguage (
	customerrequestedlanguagecustomerid, 
	customerrequestedlanguagelanguageid,
	customerrequestedlanguagemodifiedby)  
values (tempcustomerid,templanguagetypeidid,create_modifiedby); 

-- Massage the Admin data for insert

if 	create_adminfirstname isNull
	then
		create_adminfirstname = 'Unkown';
End if;		
		
if 	create_adminfirstname isNull
	then
		create_adminlastname = 'Unkown';
End if;		
				
if create_adminemailaddress isNull 
	then
		tempusername = create_adminphonenumber;
		create_adminemailaddress = 'Unknown';		
	Else 
		tempusername = create_adminemailaddress;
End if;

-- insert the worker  
-- exand this to see if the worker exists?
-- i am assuming you can't get to here if the admin already existed

tempworkeridentitysystemid = (select systagid 
					  		from systag
					  		where systaguuid = create_adminidentitysystemuuid);

tempworkeruuid = (select workeruuid
				 	from worker 
				 	where workeridentityid = create_adminidentityid
				  		and workeridentitysystemuuid = create_adminidentitysystemuuid);
						

if tempworkeruuid isNull
	then
		INSERT INTO public.worker(
			workerlastname, 
			workerfirstname, 
			workeremail, 
			workerstartdate, 
			workerfullname, 
			workerlanguageid, 
			workerusername, -- this is email or phone number
			workerpassword,  -- We probably should dump this, but it is required right now. 
			workeridentityid,
			workeridentitysystemid,
			workeridentitysystemuuid,
			workermodifiedby)
		values( 
			create_adminlastname,
			create_adminfirstname,  
			create_adminemailaddress,
			clock_timestamp(),
			create_adminfirstname||' '||create_adminlastname, 
			templanguagetypeidid,
			tempusername,
			tempusername,  -- We probably should dump this, but it is required right now.  
			create_adminidentityid,  
			tempworkeridentitysystemid,
			create_adminidentitysystemuuid, 
			create_modifiedby)	
		Returning workeruuid into tempworkeruuid;
end if;

-- insert the worker instance

INSERT INTO public.workerinstance(
	workerinstanceworkerid, 
	workerinstanceworkeruuid,
	workerinstancecustomerid,
	workerinstancecustomeruuid,
	workerinstancestartdate, 
	workerinstancelanguageid,
	workerinstancelanguageuuid,
	workerinstancescanid, 
	workerinstanceuserroleid,
	workerinstanceuserroleuuid,
	workerinstancemodifiedby)
select 
	workerid,
	workeruuid,
	tempcustomerid,
	create_customeruuid,
	clock_timestamp(),
	templanguagetypeidid,
	create_languagetypeuuid,
	workerusername,  
	systagid,
	systaguuid,
	create_modifiedby
from worker
	inner join systag
		on systaguuid = '1d8c3097-23f5-4cac-a4c5-ad0a75a181e4'
where workeruuid = tempworkeruuid
returning  workerinstanceuuid into create_adminuuid;

-- create the site. Could be migrate to the crud code.  I am just hardcoding for now. 
-- insert the custag 
-- Check if it exists first

tempcustagsitetypeid = (select custagid 
						from custag 
							inner join customer
								on custagcustomerid = customerid
						where custagtype = 'site'
							and (create_customeruuid = custagcustomeruuid
								or tempcustomerid = custagcustomerid));

if tempcustagsitetypeid isNull
	then 
		INSERT INTO public.languagemaster(
			languagemastercustomerid, 
			languagemastersourcelanguagetypeid, 
			languagemastersource, 
			languagemastermodifiedby)
			VALUES (tempcustomerid,20,'site',create_modifiedby)
			Returning languagemasterid into templanguagemasterid;
	
		INSERT INTO public.custag(
			custagcustomerid,
			custagcustomeruuid, 
			custagsystagid,
			custagsystaguuid,
			custagnameid, 			
			custagtype, 
			custagstartdate, 
			custagmodifiedby
			)
			VALUES (
				tempcustomerid,
				create_customeruuid, 
				713,
				'9e5d9651-f928-4fcd-a1b7-e4027ea774ce',
				templanguagemasterid,
				'site',
				clock_timestamp(),
				create_modifiedby)
		Returning custagid into tempcustagsitetypeid;
		
end if;

-- see if the site exists already

tempsiteid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagsitetypeid
			 	and locationistop = true
			 	and locationfullname = create_sitename
			 	and languagetranslationtypeid = templanguagetypeidid);

if create_timezone isNull
	then 
		templocationtimezone = 'UTC';
	Else 
		templocationtimezone = create_timezone;
End if;

if tempsiteid isNull
	then
		INSERT INTO public.languagemaster(
			languagemastercustomerid, 
			languagemastersourcelanguagetypeid, 
			languagemastersource, 
			languagemastermodifiedby)
		VALUES (tempcustomerid,templanguagetypeidid,'site',create_modifiedby)
		Returning languagemasterid into templanguagemasterid;
		
		INSERT INTO public.location(
			locationcustomerid,
			locationlookupname,
			locationistop,
			locationiscornerstone,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationmodifiedby)
		values(	
			tempcustomerid,
			'site',
			TRUE,
			FALSE,
			FALSE,
			tempcustagsitetypeid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   
			create_modifiedby)
		Returning locationid into tempsiteid;

		update location 
		set locationsiteid = locationid,
			locationparentid = locationid
		where locationid = tempsiteid;
end if;

				
-- create the entry. Could be migrate to the crud code.  I am just hardcoding for now. 
-- insert the custag 
-- Check if it exists first

tempcustagentrytypeid = (select custagid 
						from custag 
							inner join customer
								on custagcustomerid = customerid
						where custagtype = 'entry'
							and (create_customeruuid = custagcustomeruuid
								or tempcustomerid = custagcustomerid));

if tempcustagentrytypeid isNull
	then 
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			   tempsiteid,
			20, 	
			'entry',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid,
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				create_customeruuid,
				713,  -- Systagid for Location Category
				'9e5d9651-f928-4fcd-a1b7-e4027ea774ce', -- Systaguuid for Location Category
				templanguagemasterid, 
				'entry',
				clock_timestamp(),
				create_modifiedby)
		Returning custagid,custaguuid into tempcustagentrytypeid,tempcustagentrytypeuuid;

				
end if;

-- see if the entry exists already

tempentryid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagentrytypeid
			  	and locationparentid = tempsiteid
			 	and locationistop = false
			 	and locationfullname = 'entry'
			 	and languagetranslationtypeid = 20);

if tempentryid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			tempsiteid,
			20,
			'entry',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationsiteid,
			locationparentid,
			locationlookupname,
			locationscanid,
			locationistop,
			locationiscornerstone,
			locationcornerstoneorder,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationmodifiedby)
		values(	
			tempcustomerid,
			tempsiteid,
			tempsiteid,
			'entry',
			'ENT01',
			FALSE,
			TRUE,
			1,			
			FALSE,
			tempcustagentrytypeid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   
			create_modifiedby)
		Returning locationid into tempentryid;
						 
		update location
		set locationcornerstoneid = tempentryid
		where locationid = tempentryid;

end if;

-- create the break. Could be migrate to the crud code.  I am just hardcoding for now. 
-- insert the custag 
-- Check if it exists first

tempcustagbreaktypeid = (select custagid 
						from custag 
							inner join customer
								on custagcustomerid = customerid
						where custagtype = 'break'
							and (create_customeruuid = custagcustomeruuid
								or tempcustomerid = custagcustomerid));

if tempcustagbreaktypeid isNull
	then 
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			   tempsiteid,
			20, 	
			'break',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid,
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				create_customeruuid,
				713,  -- Systagid for Location Category
				'9e5d9651-f928-4fcd-a1b7-e4027ea774ce', -- Systaguuid for Location Category
				templanguagemasterid, 
				'break',
				clock_timestamp(),
				create_modifiedby)
		Returning custagid,custaguuid into tempcustagbreaktypeid,tempcustagbreaktypeuuid;
				
end if;

-- see if the break exists already

tempbreakid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagbreaktypeid
			  	and locationparentid = tempsiteid
			 	and locationistop = false
			 	and locationfullname = 'break'
			 	and languagetranslationtypeid = 20);

if tempbreakid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			tempsiteid,
			20,
			'break',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationsiteid,
			locationparentid,
			locationlookupname,
			locationscanid,
			locationistop,
			locationiscornerstone,
			locationcornerstoneorder,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationmodifiedby)
		values(	
			tempcustomerid,
			tempsiteid,
			tempsiteid,
			'break',
			'BRE01',
			FALSE,
			TRUE,
			1,			
			FALSE,
			tempcustagbreaktypeid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   
			create_modifiedby)
		Returning locationid into tempbreakid;
						 
		update location
		set locationcornerstoneid = tempbreakid
		where locationid = tempbreakid;

end if;

-- Add in worktemplates for the site id and location types
-- Add in Clock IN/OUT with entry location type

insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Clock IN/OUT',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.worktemplate(
	worktemplatecustomerid,
	worktemplatesiteid,
	worktemplatenameid,
	worktemplateneedstranslation,
	worktemplateallowondemand,
	worktemplateworkfrequencyid,
	worktemplatemodifiedby)
values
	(tempcustomerid,
	tempsiteid,
	templanguagemasterid,
	FALSE,
	TRUE,
	1, -- this is placeholder for the frequencyid we are about to create
	create_modifiedby
	)
Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

-- Add in the workfrequency for the template

INSERT INTO public.workfrequency(
	workfrequencyworktemplateid,
	workfrequencycustomerid,
	workfrequencytypeid,
	workfrequencyvalue,
	workfrequencystartdate,
	workfrequencymodifiedby)
values 
	(tempworktemplateid,
	tempcustomerid,
	740,
	1,
	clock_timestamp(),
	create_modifiedby
	)
Returning workfrequencyid into tempworkfrequencyid;

update worktemplate w
set worktemplateworkfrequencyid = tempworkfrequencyid
where worktemplateid = tempworktemplateid;

-- add the contraints

INSERT INTO worktemplateconstraint (
    worktemplateconstraintcustomerid,
	worktemplateconstraintcustomeruuid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintconstraintid,     -- Location Type in custag
    worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
    worktemplateconstraintmodifiedby
)
values (tempcustomerid,
		create_customeruuid,
		tempworktemplateuuid,
		tempcustagbreaktypeuuid,
		'd8dfd8de-ffdc-4472-8d38-171351668e9d',
		create_modifiedby
		);
		
-- Next template for in progress

INSERT INTO public.worktemplatenexttemplate(
  worktemplatenexttemplateprevioustemplateid,
  worktemplatenexttemplatenexttemplateid,
  worktemplatenexttemplatecustomerid,
  worktemplatenexttemplateviastatuschange,
  worktemplatenexttemplateviastatuschangeid,
  worktemplatenexttemplatesiteid,
  worktemplatenexttemplatetypeid,
	worktemplatenexttemplatemodifiedby
)
values(tempworktemplateid,
	  tempworktemplateid,
	  tempcustomerid,
	  TRUE,
	  707,
	  tempsiteid,
	  811,
	  create_modifiedby);
	
-- set tiny tendies types

insert into worktemplatetype as w
(worktemplatetypeworktemplateuuid, 
 worktemplatetypesystaguuid, 
 worktemplatetypeworktemplateid, 
 worktemplatetypesystagid,
worktemplatetypecustomerid,
worktemplatetypecustomeruuid)
values (tempworktemplateuuid,
		'b2af4084-1f19-4e25-9890-db003ba7a4c3', 
		tempworktemplateid,
		883,  
		tempcustomerid,
		create_customeruuid);

-- Add in workresults here
--"Time At Task"

INSERT INTO public.workresult(
  workresultworktemplateid,
  workresultcustomerid,
  workresultsiteid,
  workresultfortask,
  workresultforaudit,
  workresulttypeid,
  workresultlanguagemasterid,
  workresultorder,
  workresultisvisible,
	workresultmodifiedby
 )
values(
	tempworktemplateid,
	tempcustomerid,
	tempsiteid,
	TRUE,
	FALSE,  
	737,
	4367,  
	0,  
	FALSE,  
	create_modifiedby);

--"Worker"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	1, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	850,
	FALSE,
	create_modifiedby);

--"Start Location"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	2, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	852,
	FALSE,
	create_modifiedby);
	
--"End Location"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	3, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	852,
	FALSE,
	create_modifiedby);

--"Start Override"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	868,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	4, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  	TRUE,
	null,
	FALSE,
	create_modifiedby);

--"End Override"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	868,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	5, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  	TRUE,
	null,
	FALSE,
	create_modifiedby);

--"Override By"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Override By',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	6, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	850,
	FALSE,
	create_modifiedby);

--"Location"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	996, 
	FALSE,
	FALSE,
	FALSE,
	FALSE,
  TRUE,
	852,
	TRUE,
	create_modifiedby)
Returning workresultid into tempworkresultid;

--"Worker"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	997, 
	FALSE,
	FALSE,
	FALSE,
	FALSE,
  TRUE,
	850,
	TRUE,
	create_modifiedby);

-- Add in instances 
-- timesheet only has ondemand

INSERT INTO public.workinstance(
	workinstancecustomerid,
	workinstanceworktemplateid,
	workinstancesiteid,
	workinstancetypeid,
	workinstancestatusid,
	workinstancetargetstartdate,
	workinstancetimezone,
	workinstancerefid, -- put location here to start
	workinstancemodifiedby)
values(
	tempcustomerid,
	tempworktemplateid,
	tempsiteid,
	811,  -- this is the work type for task.
	706,  -- this is the status for Open.
	clock_timestamp(),
	templocationtimezone,
	tempentryid,
	create_modifiedby)
Returning workinstanceid into tempworkinstanceid;

update workinstance
set workinstanceoriginatorworkinstanceid = workinstanceid
where  workinstancecustomerid = tempcustomerid
	and workinstanceoriginatorworkinstanceid isNull;
	
-- Insert for tasks
INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstanceworkresultid,
	workresultinstancevalue,
	workresultinstancemodifiedby
)
values (
	tempworkinstanceid,
	tempcustomerid,
	tempworkresultid,
	tempentryid,
	create_modifiedby);

-- Add in Break IN/OUT with entry location type

insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Break IN/OUT',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.worktemplate(
	worktemplatecustomerid,
	worktemplatesiteid,
	worktemplatenameid,
	worktemplateneedstranslation,
	worktemplateallowondemand,
	worktemplateworkfrequencyid,
	worktemplatemodifiedby)
values
	(tempcustomerid,
	tempsiteid,
	templanguagemasterid,
	FALSE,
	TRUE,
	1, -- this is placeholder for the frequencyid we are about to create
	create_modifiedby
	)
Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

-- Add in the workfrequency for the template

INSERT INTO public.workfrequency(
	workfrequencyworktemplateid,
	workfrequencycustomerid,
	workfrequencytypeid,
	workfrequencyvalue,
	workfrequencystartdate,
	workfrequencymodifiedby)
values 
	(tempworktemplateid,
	tempcustomerid,
	740,
	1,
	clock_timestamp(),
	create_modifiedby
	)
Returning workfrequencyid into tempworkfrequencyid;

update worktemplate w
set worktemplateworkfrequencyid = tempworkfrequencyid
where worktemplateid = tempworktemplateid;

-- add the contraints

INSERT INTO worktemplateconstraint (
    worktemplateconstraintcustomerid,
	worktemplateconstraintcustomeruuid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintconstraintid,     -- 'Row'
    worktemplateconstraintconstrainedtypeid, -- Location
    worktemplateconstraintmodifiedby
)
values (tempcustomerid,
		create_customeruuid,
		tempworktemplateuuid,
		tempcustagentrytypeuuid,
		'd8dfd8de-ffdc-4472-8d38-171351668e9d',
		create_modifiedby
		);

-- Next template for in progress

INSERT INTO public.worktemplatenexttemplate(
  worktemplatenexttemplateprevioustemplateid,
  worktemplatenexttemplatenexttemplateid,
  worktemplatenexttemplatecustomerid,
  worktemplatenexttemplateviastatuschange,
  worktemplatenexttemplateviastatuschangeid,
  worktemplatenexttemplatesiteid,
  worktemplatenexttemplatetypeid,
	worktemplatenexttemplatemodifiedby
)
values(tempworktemplateid,
	  tempworktemplateid,
	  tempcustomerid,
	  TRUE,
	  707,
	  tempsiteid,
	  811,
	  create_modifiedby);
	
-- set tiny tendies types

insert into worktemplatetype as w
(worktemplatetypeworktemplateuuid, 
 worktemplatetypesystaguuid, 
 worktemplatetypeworktemplateid, 
 worktemplatetypesystagid,
worktemplatetypecustomerid,
worktemplatetypecustomeruuid)
values (tempworktemplateuuid,
		'b6efaf15-2818-4e1d-bcc9-26d171496d8d', 
		tempworktemplateid,
		884,  
		tempcustomerid,
		create_customeruuid);

-- Add in workresults here
--"Time At Task"

INSERT INTO public.workresult(
  workresultworktemplateid,
  workresultcustomerid,
  workresultsiteid,
  workresultfortask,
  workresultforaudit,
  workresulttypeid,
  workresultlanguagemasterid,
  workresultorder,
  workresultisvisible,
	workresultmodifiedby
 )
values(
	tempworktemplateid,
	tempcustomerid,
	tempsiteid,
	TRUE,
	FALSE,  
	737,
	4367,  
	0,  
	FALSE,  
	create_modifiedby);

--"Worker"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	1, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	850,
	FALSE,
	create_modifiedby);

--"Start Location"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	2, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	852,
	FALSE,
	create_modifiedby);
	
--"End Location"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	3, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	852,
	FALSE,
	create_modifiedby);

--"Start Override"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	868,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	4, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  	TRUE,
	null,
	FALSE,
	create_modifiedby);

--"End Override"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	868,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	5, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  	TRUE,
	null,
	FALSE,
	create_modifiedby);

--"Override By"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Override By',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	6, 
	FALSE,
	TRUE,
	TRUE,
	FALSE,
  TRUE,
	850,
	FALSE,
	create_modifiedby);

--"Location"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	996, 
	FALSE,
	FALSE,
	FALSE,
	FALSE,
  TRUE,
	852,
	TRUE,
	create_modifiedby)
Returning workresultid into tempworkresultid;

--"Worker"
insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
	workresultcustomerid, 
	workresulttypeid, 
	workresultforaudit, 
	workresultstartdate, 
	workresultlanguagemasterid, 
	workresultsiteid, 
	workresultorder, 
	workresultiscalculated, 
	workresultiseditable, 
	workresultisvisible, 
	workresultisrequired, 
	workresultfortask, 
	workresultentitytypeid, 
	workresultisprimary,
	workresultmodifiedby) 
values(
  tempworktemplateid,
  tempcustomerid,
	848,
  false,
	clock_timestamp(),
  templanguagemasterid,
  tempsiteid,
	997, 
	FALSE,
	FALSE,
	FALSE,
	FALSE,
  TRUE,
	850,
	TRUE,
	create_modifiedby);

-- Add in instances 
-- timesheet only has ondemand

INSERT INTO public.workinstance(
	workinstancecustomerid,
	workinstanceworktemplateid,
	workinstancesiteid,
	workinstancetypeid,
	workinstancestatusid,
	workinstancetargetstartdate,
	workinstancetimezone,
	workinstancerefid, -- put location here to start
	workinstancemodifiedby)
values(
	tempcustomerid,
	tempworktemplateid,
	tempsiteid,
	811,  -- this is the work type for task.
	706,  -- this is the status for Open.
	clock_timestamp(),
	templocationtimezone,
	tempentryid,
	create_modifiedby)
Returning workinstanceid into tempworkinstanceid;
	
update workinstance
set workinstanceoriginatorworkinstanceid = workinstanceid
where  workinstancecustomerid = tempcustomerid
	and workinstanceoriginatorworkinstanceid isNull;
	
-- Insert for tasks
INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstanceworkresultid,
	workresultinstancevalue,
	workresultinstancemodifiedby
)
values (
	tempworkinstanceid,
	tempcustomerid,
	tempworkresultid,
	tempentryid,
	create_modifiedby);

-- Cleanup widget and format
-- Number
update workresult
set workresultwidgetid = 407, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=701 
and workresultwidgetid is null;

-- Clicker
update workresult
set workresultwidgetid = 406,
workresulttypeid = 701, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=700 
and workresultwidgetid is null;

-- boolean
update workresult
set workresultwidgetid = 414, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=754 
and workresultwidgetid is null;

-- tat
update workresult
set workresultwidgetid = 413, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=737 
and workresultwidgetid is null;

--Text
update workresult
set workresultwidgetid = 408, 
workresulttypeid = 771,
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=702 
and workresultwidgetid is null;

--Sentiment
update workresult
set workresultwidgetid = 410, 
workresulttypeid = 701,
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=704 
and workresultwidgetid is null;

--String
update workresult
set workresultwidgetid = 412, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=771 
and workresultwidgetid is null;

-- entity
update workresult
set workresultwidgetid = 415, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=848 
and workresultwidgetid is null;

-- date
update workresult
set workresultwidgetid = 419, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=868 
and workresultwidgetid is null;

-- Geolocation
update workresult
set workresultwidgetid = 463,
workresulttypeid = 771, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=890 
and workresultwidgetid is null;

-- Add in customerconfigs

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_worker_list(text,text,text,bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_worker_list(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_siteid bigint, read_languagetypeuuid text)
 RETURNS TABLE(workerinstanceid bigint, workerinstanceuuid text, workerinstancecustomerid bigint, workerinstancecustomeruuid text, workerinstancecustomername text, workerinstancesiteid bigint, workerinstancestartdate timestamp with time zone, workerinstanceenddate timestamp with time zone, workerinstancelanguageid bigint, workerinstancelanguageuuid text, workerinstancelanguagetype text, workerinstanceexternalid text, workerinstanceexternalsystemid bigint, workerinstanceexternalsystemuuid text, workerinstanceexternalsystemname text, workerinstancescanid text, workerinstanceuserroleid bigint, workerinstanceuserroleuuid text, workerinstanceuserrolename text, workerid bigint, workeruuid text, workerfirstname text, workerlastname text, workeremail text, workerfullname text, workerusername text, workerphonenumber text, workerexternalid text, workeridentityid text, workeridentitysystemid bigint, workeridentitysystemuuid text, workeridentitysystemname text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	templanguagetypeid bigint;

Begin
-- does not work for sites


	-- Check if customer exists
    PERFORM * FROM public.customer 
				WHERE (read_customeruuid = customeruuid 
					or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	-- We probably should tie workerinstance to site
	-- Check if site exists  -- Check for Null first?  

if read_siteid notnull
	then
		PERFORM * FROM public.location loc
						inner join customer
							on customerid = loc.locationcustomerid		
					WHERE loc.locationid = read_siteid
						and loc.locationistop = tue;
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'Site does not exist for customer';
	    END IF;
end if;

	tempcustomerid = (select customerid 
						from customer 
						where ('customer_42cb94ee-ec07-4d33-88ed-9d49659e68be' = customeruuid 
							or (null = customerexternalid
							and null = customerexternalsystemuuid))); 

	templanguagetypeid = (select systagid 
						  from systag
						  where systaguuid = null);
	
	if templanguagetypeid isNull
		then templanguagetypeid = 20;
	end if;

RETURN QUERY SELECT 
	wi.workerinstanceid, 
	wi.workerinstanceuuid, 	
	customerid as workerinstancecustomerid,
	customeruuid as workerinstancecustomeruuid, 
	customername as workerinstancecustomername, 
	read_siteid,
	wi.workerinstancestartdate, 
	wi.workerinstanceenddate, 
	lan.systagid as workerinstancelanguageid, 
	lan.systaguuid as workerinstancelanguageuuid, 
	lan.systagtype as workerinstancelanguagetype,  
	wi.workerinstanceexternalid, 
	ext.systagid as workerinstanceexternalsystemid,
	ext.systaguuid as workerinstanceexternalsystemuuid,	
	ext.systagtype as workerinstanceexternalsystemname, 
	wi.workerinstancescanid, 
	role.systagid as workerinstanceuserroleid, 
	role.systaguuid as workerinstanceuserroleuuid,
	role.systagtype as workerinstanceuserrolename, 
	w.workerid,      
	w.workeruuid, 
	w.workerfirstname,
	w.workerlastname, 
	w.workeremail, 
	w.workerfullname, 
	w.workerusername, 
	w.workerphonenumber, 
	w.workerexternalid, 
	w.workeridentityid, 
	ide.systagid as workeridentitysystemid, 
	ide.systaguuid as workeridentitysystemuuid, 
	ide.systagtype as workeridentitysystemname  
FROM public.workerinstance wi
	inner join worker w
		on w.workerid = wi.workerinstanceworkerid
	inner join customer
		on customerid = wi.workerinstancecustomerid
			and wi.workerinstancecustomerid = tempcustomerid
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join systag role
		on role.systagid =wi. workerinstanceuserroleid
	left join systag ext
		on ext.systagid = wi.workerinstanceexternalsystemid
	left join systag ide
		on ide.systagid = w.workeridentitysystemid;

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_worker_list(text,text,text,bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_worker_list(text,text,text,bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_worker_list(text,text,text,bigint,text) TO tendreladmin WITH GRANT OPTION;

-- Type: FUNCTION ; Name: zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.zzz_crud_worker_read(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_siteid bigint, read_workerinstanceid bigint, read_workerinstanceuuid text, read_workerexternalid text, read_workerexternalsystemid bigint, read_workerexternalsystemuuid text, read_workeridentityid text, read_workeridentitysystemid bigint, read_workeridentitysystemuuid text, read_read_languagetypeuuid text)
 RETURNS TABLE(workerinstanceid bigint, workerinstanceuuid text, workerinstancecustomerid bigint, workerinstancecustomeruuid text, workerinstancecustomername text, workerinstancesiteid bigint, workerinstancestartdate timestamp with time zone, workerinstanceenddate timestamp with time zone, workerinstancelanguageid bigint, workerinstancelanguageuuid text, workerinstancelanguagetype text, workerinstanceexternalid text, workerinstanceexternalsystemid bigint, workerinstanceexternalsystemuuid text, workerinstanceexternalsystemname text, workerinstancescanid text, workerinstanceuserroleid bigint, workerinstanceuserroleuuid text, workerinstanceuserrolename text, workerid bigint, workeruuid text, workerfirstname text, workerlastname text, workeremail text, workerfullname text, workerusername text, workerphonenumber text, workerexternalid text, workeridentityid text, workeridentitysystemid bigint, workeridentitysystemuuid text, workeridentitysystemname text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	templanguagetypeid bigint;

Begin
-- does not work for sites

	-- Check if customer exists
    PERFORM * FROM public.customer 
				WHERE (read_customeruuid = customeruuid 
					or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid 
						from customer 
						where ('customer_42cb94ee-ec07-4d33-88ed-9d49659e68be' = customeruuid 
							or (null = customerexternalid
							and null = customerexternalsystemuuid))); 

	-- We probably should tie workerinstance to site
	-- Check if site exists  -- Check for Null first?  

if read_siteid notnull
	then
		PERFORM * FROM public.location loc
						inner join customer
							on customerid = loc.locationcustomerid		
					WHERE loc.locationid = read_siteid
						and loc.locationistop = tue;
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'Site does not exist for customer';
	    END IF;
end if;

	-- check if the workerinstnace is valid for customer
	-- check if the workerinstnace is valid for site (not doing this check yet)
	-- check if a valid workerinstance

    PERFORM * FROM public.workerinstance wi
				inner join customer
					on customerid = wi.workerinstancecustomerid
						and wi.workerinstancecustomerid = tempcustomerid
				inner join worker wor
					on wor.workerid = wi.workerinstanceworkerid
				WHERE wi.workerinstanceid = read_workerinstanceid 
						or wi.workerinstanceuuid = read_workerinstanceuuid
						or (wi.workerinstanceexternalid = read_workerexternalid 
							and (wi.workerinstanceexternalsystemid = read_workerexternalsystemid 
								--or wi.workerinstanceexternalsystemuuid = read_workerexternalsystemuuid
								))
						or (wor.workeridentityid = read_workeridentityid 
							and (wor.workeridentitysystemid =  read_workeridentitysystemid 
								or wor.workeridentitysystemuuid = read_workeridentitysystemuuid ));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Worker does not exist';
    END IF;

	templanguagetypeid = (select systagid 
						  from systag
						  where systaguuid = null);
	
	if templanguagetypeid isNull
		then templanguagetypeid = 20;
	end if;

RETURN QUERY SELECT 
	wi.workerinstanceid, 
	wi.workerinstanceuuid, 	
	customerid as workerinstancecustomerid,
	customeruuid as workerinstancecustomeruuid, 
	customername as workerinstancecustomername, 
	read_siteid,
	wi.workerinstancestartdate, 
	wi.workerinstanceenddate, 
	lan.systagid as workerinstancelanguageid, 
	lan.systaguuid as workerinstancelanguageuuid, 
	lan.systagtype as workerinstancelanguagetype,  
	wi.workerinstanceexternalid, 
	ext.systagid as workerinstanceexternalsystemid,
	ext.systaguuid as workerinstanceexternalsystemuuid,	
	ext.systagtype as workerinstanceexternalsystemname, 
	wi.workerinstancescanid, 
	role.systagid as workerinstanceuserroleid, 
	role.systaguuid as workerinstanceuserroleuuid,
	role.systagtype as workerinstanceuserrolename, 
	w.workerid,      
	w.workeruuid, 
	w.workerfirstname,
	w.workerlastname, 
	w.workeremail, 
	w.workerfullname, 
	w.workerusername, 
	w.workerphonenumber, 
	w.workerexternalid, 
	w.workeridentityid, 
	ide.systagid as workeridentitysystemid, 
	ide.systaguuid as workeridentitysystemuuid, 
	ide.systagtype as workeridentitysystemname  
FROM public.workerinstance wi
	inner join worker w
		on w.workerid = wi.workerinstanceworkerid
	inner join customer
		on customerid = wi.workerinstancecustomerid
			and wi.workerinstancecustomerid = tempcustomerid
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join systag role
		on role.systagid =wi. workerinstanceuserroleid
	left join systag ext
		on ext.systagid = wi.workerinstanceexternalsystemid
	left join systag ide
		on ide.systagid = w.workeridentitysystemid
WHERE wi.workerinstanceid = read_workerinstanceid 
		or wi.workerinstanceuuid = read_workerinstanceuuid
		or (wi.workerinstanceexternalid = read_workerexternalid 
			and (wi.workerinstanceexternalsystemid = read_workerexternalsystemid 
				--or wi.workerinstanceexternalsystemuuid = read_workerexternalsystemuuid
				))
		or (w.workeridentityid = read_workeridentityid 
			and (w.workeridentitysystemid =  read_workeridentitysystemid 
				or w.workeridentitysystemuuid = read_workeridentitysystemuuid ));

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text) TO tendreladmin WITH GRANT OPTION;

-- Type: TABLE ; Name: _customerToregistereddevice; Owner: tendreladmin

CREATE TABLE "_customerToregistereddevice" (
    "A" bigint NOT NULL,
    "B" bigint NOT NULL
);


ALTER TABLE "_customerToregistereddevice" ADD CONSTRAINT "_customerToregistereddevice_A_fkey" FOREIGN KEY ("A") REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "_customerToregistereddevice" ADD CONSTRAINT "_customerToregistereddevice_B_fkey" FOREIGN KEY ("B") REFERENCES registereddevice(registereddeviceid) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE UNIQUE INDEX "_customerToregistereddevice_AB_unique" ON public."_customerToregistereddevice" USING btree ("A", "B");
CREATE INDEX "_customerToregistereddevice_B_index" ON public."_customerToregistereddevice" USING btree ("B");

GRANT INSERT ON "_customerToregistereddevice" TO authenticated;
GRANT SELECT ON "_customerToregistereddevice" TO authenticated;
GRANT UPDATE ON "_customerToregistereddevice" TO authenticated;
GRANT DELETE ON "_customerToregistereddevice" TO graphql;
GRANT INSERT ON "_customerToregistereddevice" TO graphql;
GRANT REFERENCES ON "_customerToregistereddevice" TO graphql;
GRANT SELECT ON "_customerToregistereddevice" TO graphql;
GRANT TRIGGER ON "_customerToregistereddevice" TO graphql;
GRANT TRUNCATE ON "_customerToregistereddevice" TO graphql;
GRANT UPDATE ON "_customerToregistereddevice" TO graphql;

-- Type: TABLE ; Name: _prisma_migrations; Owner: tendreladmin

CREATE TABLE _prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone NOT NULL,
    applied_steps_count integer NOT NULL
);


ALTER TABLE _prisma_migrations ALTER started_at SET DEFAULT now();
ALTER TABLE _prisma_migrations ALTER applied_steps_count SET DEFAULT 0;

ALTER TABLE _prisma_migrations ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);

GRANT INSERT ON _prisma_migrations TO authenticated;
GRANT SELECT ON _prisma_migrations TO authenticated;
GRANT UPDATE ON _prisma_migrations TO authenticated;
GRANT DELETE ON _prisma_migrations TO graphql;
GRANT INSERT ON _prisma_migrations TO graphql;
GRANT REFERENCES ON _prisma_migrations TO graphql;
GRANT SELECT ON _prisma_migrations TO graphql;
GRANT TRIGGER ON _prisma_migrations TO graphql;
GRANT TRUNCATE ON _prisma_migrations TO graphql;
GRANT UPDATE ON _prisma_migrations TO graphql;

-- Type: TABLE ; Name: address; Owner: tendreladmin

CREATE TABLE address (
    addressid bigint GENERATED ALWAYS AS IDENTITY,
    addresscustomerid bigint,
    address1 text,
    address2 text,
    address3 text,
    addresscity text,
    addresscountryid bigint,
    addresszipcode text,
    addresstimezoneid bigint,
    addresscreatedate timestamp(3) with time zone NOT NULL,
    addressmodifieddate timestamp(3) with time zone NOT NULL,
    addressstartdate timestamp(3) with time zone,
    addressenddate timestamp(3) with time zone,
    addressisadmin boolean,
    addressstateid bigint,
    addressstatename text,
    addressexternalsystemid bigint,
    addressexternalid bigint
);


ALTER TABLE address ALTER addresscreatedate SET DEFAULT now();
ALTER TABLE address ALTER addressmodifieddate SET DEFAULT now();
ALTER TABLE address ALTER addressstartdate SET DEFAULT now();
ALTER TABLE address ALTER addressisadmin SET DEFAULT false;

ALTER TABLE address ADD CONSTRAINT address_pkey PRIMARY KEY (addressid);
ALTER TABLE address ADD CONSTRAINT address_addresscountryid_fkey FOREIGN KEY (addresscountryid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE address ADD CONSTRAINT address_addressstateid_fkey FOREIGN KEY (addressstateid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE address ADD CONSTRAINT address_addresstimezoneid_fkey FOREIGN KEY (addresstimezoneid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE address ADD CONSTRAINT customerid_fkey FOREIGN KEY (addresscustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

GRANT INSERT ON address TO authenticated;
GRANT SELECT ON address TO authenticated;
GRANT UPDATE ON address TO authenticated;
GRANT DELETE ON address TO graphql;
GRANT INSERT ON address TO graphql;
GRANT REFERENCES ON address TO graphql;
GRANT SELECT ON address TO graphql;
GRANT TRIGGER ON address TO graphql;
GRANT TRUNCATE ON address TO graphql;
GRANT UPDATE ON address TO graphql;

-- Type: SEQUENCE ; Name: address_addressid_seq; Owner: tendreladmin

ALTER TABLE address ALTER addressid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: apikey; Owner: tendreladmin

CREATE TABLE apikey (
    apikeyid bigint NOT NULL,
    apikey text NOT NULL,
    apikeycreateddate timestamp(3) with time zone NOT NULL,
    apikeymodifieddate timestamp(3) with time zone NOT NULL,
    apikeyenddate timestamp(3) with time zone,
    apikeycustomerid bigint NOT NULL,
    apikeymaxslots integer,
    apikeyexternalid text,
    apikeyexternalsystemid bigint,
    apikeymodifiedby bigint,
    apikeyrefid bigint,
    "registereddeviceRegistereddeviceid" bigint
);


ALTER TABLE apikey ALTER apikeycreateddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE apikey ALTER apikeymodifieddate SET DEFAULT CURRENT_TIMESTAMP;

CREATE SEQUENCE IF NOT EXISTS apikey_apikeyid_seq;
ALTER SEQUENCE apikey_apikeyid_seq OWNED BY apikey.apikeyid;

ALTER TABLE apikey ADD CONSTRAINT apikey_pkey PRIMARY KEY (apikeyid);
ALTER TABLE apikey ADD CONSTRAINT apikey_apikeycustomerid_fkey FOREIGN KEY (apikeycustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE apikey ADD CONSTRAINT apikey_apikeymodifiedby_fkey FOREIGN KEY (apikeymodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE apikey ADD CONSTRAINT "apikey_registereddeviceRegistereddeviceid_fkey" FOREIGN KEY ("registereddeviceRegistereddeviceid") REFERENCES registereddevice(registereddeviceid) ON UPDATE CASCADE ON DELETE SET NULL;

CREATE UNIQUE INDEX apikey_apikey_key ON public.apikey USING btree (apikey);

GRANT INSERT ON apikey TO authenticated;
GRANT SELECT ON apikey TO authenticated;
GRANT UPDATE ON apikey TO authenticated;
GRANT DELETE ON apikey TO graphql;
GRANT INSERT ON apikey TO graphql;
GRANT REFERENCES ON apikey TO graphql;
GRANT SELECT ON apikey TO graphql;
GRANT TRIGGER ON apikey TO graphql;
GRANT TRUNCATE ON apikey TO graphql;
GRANT UPDATE ON apikey TO graphql;

-- Type: SEQUENCE ; Name: apikey_apikeyid_seq; Owner: tendreladmin

CREATE SEQUENCE apikey_apikeyid_seq;


ALTER SEQUENCE apikey_apikeyid_seq
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START WITH 1
 NO CYCLE;

-- Type: TABLE ; Name: custag; Owner: tendreladmin

CREATE TABLE custag (
    custagid bigint GENERATED ALWAYS AS IDENTITY,
    custagcustomerid bigint NOT NULL,
    custagtype text NOT NULL,
    custagsystagid bigint NOT NULL,
    custagcreateddate timestamp(3) with time zone NOT NULL,
    custagmodifieddate timestamp(3) with time zone NOT NULL,
    custagstartdate timestamp(3) with time zone NOT NULL,
    custagenddate timestamp(3) with time zone,
    custagorder bigint NOT NULL,
    custagexternalsystemid bigint,
    custagnameid bigint,
    custagabbreviationid bigint,
    custagexternalid text,
    custagmodifiedby bigint,
    custagrefid bigint,
    custagrefuuid text,
    custaguuid text NOT NULL,
    custagcustomeruuid text,
    custagsystaguuid text
);


ALTER TABLE custag ALTER custagcreateddate SET DEFAULT now();
ALTER TABLE custag ALTER custagmodifieddate SET DEFAULT now();
ALTER TABLE custag ALTER custagstartdate SET DEFAULT now();
ALTER TABLE custag ALTER custagorder SET DEFAULT 1;
ALTER TABLE custag ALTER custaguuid SET DEFAULT concat('custag_', gen_random_uuid());

ALTER TABLE custag ADD CONSTRAINT custag_pkey PRIMARY KEY (custagid);
ALTER TABLE custag ADD CONSTRAINT custag_custagabbreviationid_fkey FOREIGN KEY (custagabbreviationid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE custag ADD CONSTRAINT custag_custagcustomerid_fkey FOREIGN KEY (custagcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE custag ADD CONSTRAINT custag_custagcustomeruuid_fkey FOREIGN KEY (custagcustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE custag ADD CONSTRAINT custag_custagmodifiedby_fkey FOREIGN KEY (custagmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE custag ADD CONSTRAINT custag_custagnameid_fkey FOREIGN KEY (custagnameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;

CREATE UNIQUE INDEX custag_custagcustomerid_custagsystagid_custagtype_key ON public.custag USING btree (custagcustomerid, custagsystagid, custagtype);
CREATE UNIQUE INDEX custag_custagcustomerid_custagtype_key ON public.custag USING btree (custagcustomerid, custagtype);
CREATE UNIQUE INDEX custag_custaguuid_key ON public.custag USING btree (custaguuid);

GRANT INSERT ON custag TO authenticated;
GRANT SELECT ON custag TO authenticated;
GRANT UPDATE ON custag TO authenticated;
GRANT DELETE ON custag TO graphql;
GRANT INSERT ON custag TO graphql;
GRANT REFERENCES ON custag TO graphql;
GRANT SELECT ON custag TO graphql;
GRANT TRIGGER ON custag TO graphql;
GRANT TRUNCATE ON custag TO graphql;
GRANT UPDATE ON custag TO graphql;

-- Type: SEQUENCE ; Name: custag_custagid_seq; Owner: tendreladmin

ALTER TABLE custag ALTER custagid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: customer; Owner: tendreladmin

CREATE TABLE customer (
    customerid bigint GENERATED ALWAYS AS IDENTITY,
    customername text NOT NULL,
    customerstartdate timestamp(3) with time zone,
    customerenddate timestamp(3) with time zone,
    customerexternalsystemid bigint,
    customercreateddate timestamp(3) with time zone NOT NULL,
    customermodifieddate timestamp(3) with time zone NOT NULL,
    customerexternalid text,
    customerlanguagetypeid bigint NOT NULL,
    customernamelanguagemasterid bigint,
    customernameneedstranslation boolean NOT NULL,
    customermodifiedby bigint,
    customerrefid bigint,
    customeruuid text NOT NULL,
    customerexternalsystemuuid text,
    customerlanguagetypeuuid text,
    customertypeuuid text NOT NULL
);


ALTER TABLE customer ALTER customerstartdate SET DEFAULT now();
ALTER TABLE customer ALTER customercreateddate SET DEFAULT now();
ALTER TABLE customer ALTER customermodifieddate SET DEFAULT now();
ALTER TABLE customer ALTER customerlanguagetypeid SET DEFAULT 20;
ALTER TABLE customer ALTER customernameneedstranslation SET DEFAULT true;
ALTER TABLE customer ALTER customeruuid SET DEFAULT concat('customer_', gen_random_uuid());
ALTER TABLE customer ALTER customertypeuuid SET DEFAULT '1d6b0e91-64f4-4813-b7ed-733112979460'::text;

ALTER TABLE customer ADD CONSTRAINT customer_pkey PRIMARY KEY (customerid);
ALTER TABLE customer ADD CONSTRAINT customer_customerexternalsystemuuid_fkey FOREIGN KEY (customerexternalsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customer ADD CONSTRAINT customer_customerlanguagetypeid_fkey FOREIGN KEY (customerlanguagetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customer ADD CONSTRAINT customer_customerlanguagetypeuuid_fkey FOREIGN KEY (customerlanguagetypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customer ADD CONSTRAINT customer_customermodifiedby_fkey FOREIGN KEY (customermodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customer ADD CONSTRAINT customer_customernamelanguagemasterid_fkey FOREIGN KEY (customernamelanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customer ADD CONSTRAINT customer_customertypeuuid_fkey FOREIGN KEY (customertypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX customer_customeruuid_key ON public.customer USING btree (customeruuid);

GRANT INSERT ON customer TO authenticated;
GRANT SELECT ON customer TO authenticated;
GRANT UPDATE ON customer TO authenticated;
GRANT DELETE ON customer TO graphql;
GRANT INSERT ON customer TO graphql;
GRANT REFERENCES ON customer TO graphql;
GRANT SELECT ON customer TO graphql;
GRANT TRIGGER ON customer TO graphql;
GRANT TRUNCATE ON customer TO graphql;
GRANT UPDATE ON customer TO graphql;

-- Type: TABLE ; Name: customerbillingrecord; Owner: tendreladmin

CREATE TABLE customerbillingrecord (
    customerbillingrecorduuid text NOT NULL,
    customerbillingrecordcustomerid bigint NOT NULL,
    customerbillingrecordcreateddate timestamp(3) with time zone NOT NULL,
    customerbillingrecordmodifieddate timestamp(3) with time zone NOT NULL,
    customerbillingrecordmodifiedby text NOT NULL,
    customerbillingrecordstatusuuid text NOT NULL,
    customerbillingrecordvalue text NOT NULL,
    customerbillingrecordbillingmonth integer NOT NULL,
    customerbillingrecordbillingyear integer NOT NULL,
    customerbillingrecordbillingsystemuuid text NOT NULL,
    customerbillingrecordbillingsystemeventid text,
    customerbillingrecordrefid bigint,
    customerbillingrecordrefuuid text,
    customerbillingrecordbillingid text NOT NULL,
    customerbillingrecordcustomertypename text NOT NULL,
    customerbillingrecordcustomeruuid text NOT NULL,
    customerbillingrecordcustomertypeuuid text NOT NULL
);


ALTER TABLE customerbillingrecord ALTER customerbillingrecorduuid SET DEFAULT concat('customerbillingrecord_', gen_random_uuid());

ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_pkey PRIMARY KEY (customerbillingrecorduuid);
ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordbillingsystemuu_fkey FOREIGN KEY (customerbillingrecordbillingsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordcustomerid_fkey FOREIGN KEY (customerbillingrecordcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordcustomertypeuui_fkey FOREIGN KEY (customerbillingrecordcustomertypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordmodifiedby_fkey FOREIGN KEY (customerbillingrecordmodifiedby) REFERENCES workerinstance(workerinstanceuuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordstatusuuid_fkey FOREIGN KEY (customerbillingrecordstatusuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

GRANT INSERT ON customerbillingrecord TO authenticated;
GRANT SELECT ON customerbillingrecord TO authenticated;
GRANT UPDATE ON customerbillingrecord TO authenticated;
GRANT DELETE ON customerbillingrecord TO graphql;
GRANT INSERT ON customerbillingrecord TO graphql;
GRANT REFERENCES ON customerbillingrecord TO graphql;
GRANT SELECT ON customerbillingrecord TO graphql;
GRANT TRIGGER ON customerbillingrecord TO graphql;
GRANT TRUNCATE ON customerbillingrecord TO graphql;
GRANT UPDATE ON customerbillingrecord TO graphql;

-- Type: TABLE ; Name: customerconfig; Owner: tendreladmin

CREATE TABLE customerconfig (
    customerconfiguuid text NOT NULL,
    customerconfigcreateddate timestamp(3) without time zone NOT NULL,
    customerconfigstartdate timestamp(3) without time zone NOT NULL,
    customerconfigenddate timestamp(3) without time zone,
    customerconfigmodifieddate timestamp(3) without time zone NOT NULL,
    customerconfigmodifiedby text,
    customerconfigrefid bigint,
    customerconfigrefuuid text,
    customerconfigcustomeruuid text NOT NULL,
    customerconfigsiteuuid text,
    customerconfigtypeuuid text NOT NULL,
    customerconfigvalue text,
    customerconfigvaluetypeuuid text,
    customerconfigistemplate boolean NOT NULL
);


ALTER TABLE customerconfig ALTER customerconfiguuid SET DEFAULT concat('customerconfig_', gen_random_uuid());
ALTER TABLE customerconfig ALTER customerconfigcreateddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE customerconfig ALTER customerconfigstartdate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE customerconfig ALTER customerconfigmodifieddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE customerconfig ALTER customerconfigistemplate SET DEFAULT false;

ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_pkey PRIMARY KEY (customerconfiguuid);
ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigcustomeruuid_fkey FOREIGN KEY (customerconfigcustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigmodifiedby_fkey FOREIGN KEY (customerconfigmodifiedby) REFERENCES workerinstance(workerinstanceuuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigsiteuuid_fkey FOREIGN KEY (customerconfigsiteuuid) REFERENCES location(locationuuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigtypeuuid_fkey FOREIGN KEY (customerconfigtypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigvaluetypeuuid_fkey FOREIGN KEY (customerconfigvaluetypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

GRANT INSERT ON customerconfig TO authenticated;
GRANT SELECT ON customerconfig TO authenticated;
GRANT UPDATE ON customerconfig TO authenticated;
GRANT DELETE ON customerconfig TO graphql;
GRANT INSERT ON customerconfig TO graphql;
GRANT REFERENCES ON customerconfig TO graphql;
GRANT SELECT ON customerconfig TO graphql;
GRANT TRIGGER ON customerconfig TO graphql;
GRANT TRUNCATE ON customerconfig TO graphql;
GRANT UPDATE ON customerconfig TO graphql;

-- Type: SEQUENCE ; Name: customerrequestedlanguage_customerrequestedlanguageid_seq; Owner: tendreladmin

ALTER TABLE customerrequestedlanguage ALTER customerrequestedlanguageid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: cutomer_customerid_seq; Owner: tendreladmin

ALTER TABLE customer ALTER customerid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workinstance; Owner: tendreladmin

CREATE TABLE workinstance (
    workinstanceid bigint GENERATED ALWAYS AS IDENTITY,
    workinstancecustomerid bigint NOT NULL,
    workinstanceworktemplateid bigint NOT NULL,
    workinstancesiteid bigint NOT NULL,
    workinstancetypeid bigint NOT NULL,
    workinstancestatusid bigint,
    workinstancepreviousid bigint,
    workinstancecreateddate timestamp(3) with time zone NOT NULL,
    workinstancemodifieddate timestamp(3) with time zone NOT NULL,
    workinstancetargetstartdate timestamp(3) with time zone,
    workinstancestartdate timestamp(3) with time zone,
    workinstancecompleteddate timestamp(3) with time zone,
    workinstanceexpecteddurationinseconds bigint,
    workinstanceexternalsystemid bigint,
    workinstanceexternalid text,
    workinstancesoplink text,
    workinstancetrustreasoncodeid bigint NOT NULL,
    workinstanceoriginatorworkinstanceid bigint,
    id text NOT NULL,
    version bigint NOT NULL,
    workinstancetimezone text NOT NULL,
    workinstancecompleteddatetz timestamp(3) without time zone GENERATED ALWAYS AS (timezone(workinstancetimezone, workinstancecompleteddate)) STORED,
    workinstancestartdatetz timestamp(3) without time zone GENERATED ALWAYS AS (timezone(workinstancetimezone, workinstancestartdate)) STORED,
    workinstancetargetstartdatetz timestamp(3) without time zone GENERATED ALWAYS AS (timezone(workinstancetimezone, workinstancetargetstartdate)) STORED,
    workinstancemodifiedby bigint,
    workinstancerefid bigint,
    workinstancerefuuid text,
    workinstanceproccessingstatusid bigint,
    workinstanceexpirationdate timestamp(3) with time zone,
    workinstancetexpirationdatetz timestamp(3) without time zone,
    workinstancenameid text
);


ALTER TABLE workinstance ALTER workinstancecreateddate SET DEFAULT now();
ALTER TABLE workinstance ALTER workinstancemodifieddate SET DEFAULT now();
ALTER TABLE workinstance ALTER workinstancetrustreasoncodeid SET DEFAULT 762;
ALTER TABLE workinstance ALTER id SET DEFAULT concat('work-instance_', gen_random_uuid());
ALTER TABLE workinstance ALTER version SET DEFAULT 0;
ALTER TABLE workinstance ALTER workinstancetimezone SET DEFAULT 'utc'::text;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_pkey PRIMARY KEY (workinstanceid);
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancecustomerid_fkey FOREIGN KEY (workinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancemodifiedby_fkey FOREIGN KEY (workinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancenameid_fkey FOREIGN KEY (workinstancenameid) REFERENCES languagemaster(languagemasteruuid);
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstanceproccessingstatusid_fkey FOREIGN KEY (workinstanceproccessingstatusid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancesiteid_fkey FOREIGN KEY (workinstancesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancestatusid_fkey FOREIGN KEY (workinstancestatusid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancetrustreasoncodeid_fkey FOREIGN KEY (workinstancetrustreasoncodeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancetypeid_fkey FOREIGN KEY (workinstancetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstanceworktemplateid_fkey FOREIGN KEY (workinstanceworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX workinstance_create_modify_start_dates_status_trust_key ON public.workinstance USING btree (workinstancecompleteddate, workinstancestartdate, workinstancemodifieddate, workinstancestatusid, workinstancetrustreasoncodeid);
CREATE INDEX workinstance_cust_template_completed_status_type_idx ON public.workinstance USING btree (workinstancecustomerid, workinstanceworktemplateid, workinstancecompleteddate, workinstancestatusid, workinstancetypeid);
CREATE INDEX workinstance_custtemplatetype_idx ON public.workinstance USING btree (workinstancecustomerid, workinstanceworktemplateid, workinstancetypeid);
CREATE INDEX workinstance_custtemplatetypestatus_idx ON public.workinstance USING btree (workinstancecustomerid, workinstanceworktemplateid, workinstancetypeid, workinstancestatusid);
CREATE UNIQUE INDEX workinstance_id_key ON public.workinstance USING btree (id);
CREATE INDEX workinstance_id_version_idx ON public.workinstance USING btree (id, version);
CREATE INDEX workinstance_idstatustrustreasonmodified_idx ON public.workinstance USING btree (workinstanceid, workinstancestatusid, workinstancetrustreasoncodeid, workinstancemodifieddate);
CREATE INDEX workinstance_orderby_completed_idx ON public.workinstance USING btree (workinstancecustomerid, workinstanceworktemplateid, workinstancecompleteddate);
CREATE INDEX workinstance_orderby_created_idx ON public.workinstance USING btree (workinstancecustomerid, workinstanceworktemplateid, workinstancecreateddate);
CREATE INDEX workinstance_orderby_modified_idx ON public.workinstance USING btree (workinstancecustomerid, workinstanceworktemplateid, workinstancemodifieddate);
CREATE INDEX workinstance_originatorid_idx ON public.workinstance USING btree (workinstanceoriginatorworkinstanceid);
CREATE INDEX workinstance_previousid_typeid_statusid_idx ON public.workinstance USING btree (workinstancepreviousid, workinstancetypeid, workinstancestatusid);
CREATE INDEX workinstance_previousid_typeid_statusid_templateid_idx ON public.workinstance USING btree (workinstancepreviousid, workinstancetypeid, workinstancestatusid, workinstanceworktemplateid);
CREATE INDEX workinstance_workinstancecustomerid_idx ON public.workinstance USING btree (workinstancecustomerid);
CREATE INDEX workinstance_workinstancecustomerid_workinstancemodifieddat_idx ON public.workinstance USING btree (workinstancecustomerid, workinstancemodifieddate);
CREATE UNIQUE INDEX workinstance_workinstanceid_customerid_workinstan_key ON public.workinstance USING btree (workinstanceid, workinstancecustomerid);
CREATE UNIQUE INDEX workinstance_workinstanceid_modifieddate_idx ON public.workinstance USING btree (workinstancemodifieddate, workinstanceid);
CREATE INDEX workinstance_workinstancemodifieddate_idx ON public.workinstance USING btree (workinstancemodifieddate);
CREATE UNIQUE INDEX workinstance_workinstancemodifieddate_workinstanceid_workin_key ON public.workinstance USING btree (workinstancemodifieddate, workinstanceid, workinstancecustomerid);
CREATE INDEX workinstance_workinstancepreviousid_idx ON public.workinstance USING btree (workinstancepreviousid);
CREATE INDEX workinstance_workinstancepreviousid_workinstancetypeid_idx ON public.workinstance USING btree (workinstancepreviousid, workinstancetypeid);
CREATE INDEX workinstance_workinstancestartdatetz_idx ON public.workinstance USING btree (workinstancestartdatetz);
CREATE INDEX workinstance_workinstancestatusid_idx ON public.workinstance USING btree (workinstancestatusid);
CREATE INDEX workinstance_workinstancestatusid_workinstanceid_idx ON public.workinstance USING btree (workinstancestatusid, workinstanceid);
CREATE UNIQUE INDEX workinstance_workinstancestatusid_workinstanceid_workinstan_key ON public.workinstance USING btree (workinstancestatusid, workinstanceid, workinstancemodifieddate);
CREATE INDEX workinstance_workinstancetimezone_idx ON public.workinstance USING btree (workinstancetimezone);
CREATE INDEX workinstance_workinstanceworktemplateid_idx ON public.workinstance USING btree (workinstanceworktemplateid);
CREATE INDEX workinstanceid_workinstanceexpirationdate_idx ON public.workinstance USING btree (workinstanceexpirationdate);
CREATE INDEX workinstanceid_workinstancetimezone_idx ON public.workinstance USING btree (workinstanceid, workinstancetimezone);
CREATE INDEX workinstanceid_workinstancetimezone_moddate_idx ON public.workinstance USING btree (workinstanceid, workinstancetimezone, workinstancemodifieddate);

GRANT INSERT ON workinstance TO authenticated;
GRANT SELECT ON workinstance TO authenticated;
GRANT UPDATE ON workinstance TO authenticated;
GRANT DELETE ON workinstance TO graphql;
GRANT INSERT ON workinstance TO graphql;
GRANT REFERENCES ON workinstance TO graphql;
GRANT SELECT ON workinstance TO graphql;
GRANT TRIGGER ON workinstance TO graphql;
GRANT TRUNCATE ON workinstance TO graphql;
GRANT UPDATE ON workinstance TO graphql;

-- Type: SEQUENCE ; Name: explworkinstance_workinstanceid_seq; Owner: tendreladmin

ALTER TABLE workinstance ALTER workinstanceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workresultinstance; Owner: tendreladmin

CREATE TABLE workresultinstance (
    workresultinstanceid bigint GENERATED ALWAYS AS IDENTITY,
    workresultinstanceworkinstanceid bigint NOT NULL,
    workresultinstancecustomerid bigint NOT NULL,
    workresultinstancevalue text,
    workresultinstancecreateddate timestamp(3) with time zone NOT NULL,
    workresultinstancemodifieddate timestamp(3) with time zone,
    workresultinstancestartdate timestamp(3) with time zone,
    workresultinstancecompleteddate timestamp(3) with time zone,
    workresultinstanceworkresultid bigint NOT NULL,
    workresultinstanceexternalsystemid bigint,
    workresultinstanceexternalid text,
    workresultinstancevaluelanguagemasterid bigint,
    workresultinstancevaluelanguagetypeid bigint,
    workresultinstancemodifiedby bigint,
    workresultinstancerefid bigint,
    workresultinstancerefuuid text,
    workresultinstancestatusid bigint NOT NULL,
    workresultinstanceuuid text NOT NULL,
    workresultinstancetimezone text NOT NULL,
    workresultinstancecreateddatetz timestamp(3) without time zone NOT NULL GENERATED ALWAYS AS (timezone(workresultinstancetimezone, workresultinstancecreateddate)) STORED,
    workresultinstancecompleteddatetz timestamp(3) without time zone GENERATED ALWAYS AS (timezone(workresultinstancetimezone, workresultinstancecompleteddate)) STORED,
    workresultinstancestartdatetz timestamp(3) without time zone GENERATED ALWAYS AS (timezone(workresultinstancetimezone, workresultinstancestartdate)) STORED,
    workresultinstanceentityvalue uuid
);


ALTER TABLE workresultinstance ALTER workresultinstancecreateddate SET DEFAULT now();
ALTER TABLE workresultinstance ALTER workresultinstancemodifieddate SET DEFAULT now();
ALTER TABLE workresultinstance ALTER workresultinstancestatusid SET DEFAULT 966;
ALTER TABLE workresultinstance ALTER workresultinstanceuuid SET DEFAULT concat('wri_', gen_random_uuid());
ALTER TABLE workresultinstance ALTER workresultinstancetimezone SET DEFAULT 'utc'::text;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_pkey PRIMARY KEY (workresultinstanceid);
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancecustomerid_fkey FOREIGN KEY (workresultinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstanceentityvalue_fk FOREIGN KEY (workresultinstanceentityvalue) REFERENCES entity.entityinstance(entityinstanceuuid) NOT VALID;
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancemodifiedby_fkey FOREIGN KEY (workresultinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancestatusid_fkey FOREIGN KEY (workresultinstancestatusid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancevaluelanguagemasterid_fkey FOREIGN KEY (workresultinstancevaluelanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstanceworkinstanceid_fkey FOREIGN KEY (workresultinstanceworkinstanceid) REFERENCES workinstance(workinstanceid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstanceworkresultid_fkey FOREIGN KEY (workresultinstanceworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX workresultinstance_workresultinstancecustomerid_idx ON public.workresultinstance USING btree (workresultinstancecustomerid);
CREATE UNIQUE INDEX workresultinstance_workresultinstanceuuid_key ON public.workresultinstance USING btree (workresultinstanceuuid);
CREATE INDEX workresultinstance_workresultinstancevalue_idx ON public.workresultinstance USING btree (workresultinstancevalue);
CREATE INDEX workresultinstance_workresultinstancevaluelanguagemasterid_idx ON public.workresultinstance USING btree (workresultinstancevaluelanguagemasterid);
CREATE INDEX workresultinstance_workresultinstanceworkinstanceid_idx ON public.workresultinstance USING btree (workresultinstanceworkinstanceid);
CREATE UNIQUE INDEX workresultinstance_workresultinstanceworkinstanceid_workres_key ON public.workresultinstance USING btree (workresultinstanceworkinstanceid, workresultinstanceworkresultid);
CREATE INDEX workresultinstance_workresultinstanceworkresultid_idx ON public.workresultinstance USING btree (workresultinstanceworkresultid);
CREATE INDEX workresultinstanceworkinstanceid_timezone_idx ON public.workresultinstance USING btree (workresultinstanceworkinstanceid, workresultinstancetimezone);
CREATE INDEX workresultinstanceworkinstanceid_timezone_moddate_idx ON public.workresultinstance USING btree (workresultinstanceworkinstanceid, workresultinstancetimezone, workresultinstancemodifieddate);

GRANT INSERT ON workresultinstance TO authenticated;
GRANT SELECT ON workresultinstance TO authenticated;
GRANT UPDATE ON workresultinstance TO authenticated;
GRANT DELETE ON workresultinstance TO graphql;
GRANT INSERT ON workresultinstance TO graphql;
GRANT REFERENCES ON workresultinstance TO graphql;
GRANT SELECT ON workresultinstance TO graphql;
GRANT TRIGGER ON workresultinstance TO graphql;
GRANT TRUNCATE ON workresultinstance TO graphql;
GRANT UPDATE ON workresultinstance TO graphql;

-- Type: SEQUENCE ; Name: explworkresultinstance_workresultinstanceid_seq; Owner: tendreladmin

ALTER TABLE workresultinstance ALTER workresultinstanceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: initial_workinstance; Owner: tendreladmin

CREATE TABLE initial_workinstance (
    initialworkinstanceid bigint GENERATED ALWAYS AS IDENTITY,
    initialworkinstancecustomerid bigint,
    initialworkinstanceworktemplateid bigint,
    initialworkinstancesiteid bigint,
    initialworkinstancelocationid bigint,
    initialworkinstanceworkerinstanceid bigint,
    initialworkinstancetypeid bigint,
    initialworkinstancetypename text,
    initialworkinstancestatusid bigint,
    initialworkinstancestatusname text,
    initialworkinstancepreviousid bigint,
    initialworkinstancename text,
    initialworkinstancecreateddate timestamp(3) with time zone NOT NULL,
    initialworkinstancemodifieddate timestamp(3) with time zone NOT NULL,
    initialworkinstancetargetstartdate timestamp(3) with time zone,
    actualworkinstanceid bigint,
    refid bigint,
    refidguid text
);


ALTER TABLE initial_workinstance ALTER initialworkinstancecreateddate SET DEFAULT now();
ALTER TABLE initial_workinstance ALTER initialworkinstancemodifieddate SET DEFAULT now();

ALTER TABLE initial_workinstance ADD CONSTRAINT initial_workinstance_pkey PRIMARY KEY (initialworkinstanceid);

GRANT INSERT ON initial_workinstance TO authenticated;
GRANT SELECT ON initial_workinstance TO authenticated;
GRANT UPDATE ON initial_workinstance TO authenticated;
GRANT DELETE ON initial_workinstance TO graphql;
GRANT INSERT ON initial_workinstance TO graphql;
GRANT REFERENCES ON initial_workinstance TO graphql;
GRANT SELECT ON initial_workinstance TO graphql;
GRANT TRIGGER ON initial_workinstance TO graphql;
GRANT TRUNCATE ON initial_workinstance TO graphql;
GRANT UPDATE ON initial_workinstance TO graphql;

-- Type: SEQUENCE ; Name: initial_workinstance_initialworkinstanceid_seq; Owner: tendreladmin

ALTER TABLE initial_workinstance ALTER initialworkinstanceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: invitationcode; Owner: tendreladmin

CREATE TABLE invitationcode (
    invitationcodeid bigint GENERATED ALWAYS AS IDENTITY,
    invitationcode text,
    invitationcodeinvitationtype text,
    invitationcodecustomerid bigint,
    invitationcodeinvitationtypeid bigint,
    invitationcodetransporttype text,
    invitationcodetransporttypeid bigint,
    invitationcodetransportdestination text,
    invitationcodecreatedate timestamp(3) with time zone NOT NULL,
    invitationcodemodifieddate timestamp(3) with time zone NOT NULL,
    invitationcodecloseddate timestamp(3) with time zone
);


ALTER TABLE invitationcode ALTER invitationcodecreatedate SET DEFAULT now();
ALTER TABLE invitationcode ALTER invitationcodemodifieddate SET DEFAULT now();

ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_pkey PRIMARY KEY (invitationcodeid);
ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_invitationcodecustomerid_fkey FOREIGN KEY (invitationcodecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_invitationcodeinvitationtypeid_fkey FOREIGN KEY (invitationcodeinvitationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_invitationcodetransporttypeid_fkey FOREIGN KEY (invitationcodetransporttypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

GRANT INSERT ON invitationcode TO authenticated;
GRANT SELECT ON invitationcode TO authenticated;
GRANT UPDATE ON invitationcode TO authenticated;
GRANT DELETE ON invitationcode TO graphql;
GRANT INSERT ON invitationcode TO graphql;
GRANT REFERENCES ON invitationcode TO graphql;
GRANT SELECT ON invitationcode TO graphql;
GRANT TRIGGER ON invitationcode TO graphql;
GRANT TRUNCATE ON invitationcode TO graphql;
GRANT UPDATE ON invitationcode TO graphql;

-- Type: SEQUENCE ; Name: invitationcode_invitationcodeid_seq; Owner: tendreladmin

ALTER TABLE invitationcode ALTER invitationcodeid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: languagemaster_languagemasterid_seq; Owner: tendreladmin

ALTER TABLE languagemaster ALTER languagemasterid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: languagetranslations_languagetranslationid_seq; Owner: tendreladmin

ALTER TABLE languagetranslations ALTER languagetranslationid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: location; Owner: tendreladmin

CREATE TABLE location (
    locationid bigint GENERATED ALWAYS AS IDENTITY,
    locationcustomerid bigint NOT NULL,
    locationscanid text,
    locationlookupname text,
    locationparentid bigint,
    locationistop boolean NOT NULL,
    locationiscornerstone boolean NOT NULL,
    locationcornerstoneid bigint,
    locationcornerstoneorder bigint NOT NULL,
    locationcategoryid bigint,
    locationstartdate timestamp(3) with time zone,
    locationenddate timestamp(3) with time zone,
    locationcreateddate timestamp(3) with time zone NOT NULL,
    locationmodifieddate timestamp(3) with time zone NOT NULL,
    locationcreatedby bigint,
    locationexternalsystemid bigint,
    locationexternalid text,
    locationnameid bigint NOT NULL,
    locationneedstranslation boolean NOT NULL,
    locationsiteid bigint,
    locationtimezone text NOT NULL,
    locationuuid text NOT NULL,
    locationmodifiedby bigint,
    locationrefid bigint,
    locationrefuuid text,
    locationlatitude text,
    locationlongitude text,
    locationradius numeric(65,30)
);


ALTER TABLE location ALTER locationcornerstoneorder SET DEFAULT 1;
ALTER TABLE location ALTER locationstartdate SET DEFAULT now();
ALTER TABLE location ALTER locationcreateddate SET DEFAULT now();
ALTER TABLE location ALTER locationmodifieddate SET DEFAULT now();
ALTER TABLE location ALTER locationneedstranslation SET DEFAULT true;
ALTER TABLE location ALTER locationtimezone SET DEFAULT 'utc'::text;
ALTER TABLE location ALTER locationuuid SET DEFAULT concat('location_', gen_random_uuid());

ALTER TABLE location ADD CONSTRAINT location_locationcustomerid_locationlookupname_locationpare_key UNIQUE (locationcustomerid, locationlookupname, locationparentid);
ALTER TABLE location ADD CONSTRAINT location_locationcustomerid_locationscanid_key UNIQUE (locationcustomerid, locationscanid);
ALTER TABLE location ADD CONSTRAINT location_pkey PRIMARY KEY (locationid);
ALTER TABLE location ADD CONSTRAINT location_locationcategoryid_fkey FOREIGN KEY (locationcategoryid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE location ADD CONSTRAINT location_locationcustomerid_fkey FOREIGN KEY (locationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE location ADD CONSTRAINT location_locationmodifiedby_fkey FOREIGN KEY (locationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE location ADD CONSTRAINT location_locationnameid_fkey FOREIGN KEY (locationnameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX location_locationidenddate_key ON public.location USING btree (locationid, locationenddate);
CREATE UNIQUE INDEX location_locationuuid_key ON public.location USING btree (locationuuid);

GRANT INSERT ON location TO authenticated;
GRANT SELECT ON location TO authenticated;
GRANT UPDATE ON location TO authenticated;
GRANT DELETE ON location TO graphql;
GRANT INSERT ON location TO graphql;
GRANT REFERENCES ON location TO graphql;
GRANT SELECT ON location TO graphql;
GRANT TRIGGER ON location TO graphql;
GRANT TRUNCATE ON location TO graphql;
GRANT UPDATE ON location TO graphql;

-- Type: SEQUENCE ; Name: location_locationid_seq; Owner: tendreladmin

ALTER TABLE location ALTER locationid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: locationtemplatedurationcalculation; Owner: tendreladmin

CREATE TABLE locationtemplatedurationcalculation (
    locationtemplatedurationcalculationid bigint GENERATED ALWAYS AS IDENTITY,
    locationtemplatedurationcalculationcustomerid bigint NOT NULL,
    locationtemplatedurationcalculationsiteid bigint NOT NULL,
    locationtemplatedurationcalculationworktemplateid bigint NOT NULL,
    locationtemplatedurationcalculationworktypeid bigint NOT NULL,
    locationtemplatedurationcalculationlocationid bigint NOT NULL,
    locationtemplatedurationcalculationcalculationtypeid bigint NOT NULL,
    locationtemplatedurationcalculationworkcount bigint NOT NULL,
    locationtemplatedurationcalculationp99 numeric,
    locationtemplatedurationcalculationp90 numeric,
    locationtemplatedurationcalculationp75 numeric,
    locationtemplatedurationcalculationp66 numeric,
    locationtemplatedurationcalculationp50 numeric,
    locationtemplatedurationcalculationp25 numeric,
    locationtemplatedurationcalculationp10 numeric,
    locationtemplatedurationcalculationp1 numeric,
    locationtemplatedurationcalculationmode numeric,
    locationtemplatedurationcalculationavg numeric,
    locationtemplatedurationcalculationstddevsample numeric,
    locationtemplatedurationcalculationstddevpop numeric,
    locationtemplatedurationcalculationvarsample numeric,
    locationtemplatedurationcalculationvarpop numeric,
    locationtemplatedurationcalculationenddate timestamp(3) with time zone NOT NULL,
    locationtemplatedurationcalculationcreateddate timestamp(3) with time zone NOT NULL,
    locationtemplatedurationcalculationmodifieddate timestamp(3) with time zone NOT NULL,
    locationtemplatedurationcalculationexternalid text,
    locationtemplatedurationcalculationexternalsystemid bigint,
    locationtemplatedurationcalculationmodifiedby bigint,
    locationtemplatedurationcalculationrefid bigint
);


ALTER TABLE locationtemplatedurationcalculation ALTER locationtemplatedurationcalculationcreateddate SET DEFAULT now();
ALTER TABLE locationtemplatedurationcalculation ALTER locationtemplatedurationcalculationmodifieddate SET DEFAULT now();

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT locationtemplatedurationcalculation_pkey PRIMARY KEY (locationtemplatedurationcalculationid);
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT calculationtype_fkey FOREIGN KEY (locationtemplatedurationcalculationcalculationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT customerid_fkey FOREIGN KEY (locationtemplatedurationcalculationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT locationid_fkey FOREIGN KEY (locationtemplatedurationcalculationlocationid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT locationtemplatedurationcalculation_locationtemplatedurati_fkey FOREIGN KEY (locationtemplatedurationcalculationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT siteid_fkey FOREIGN KEY (locationtemplatedurationcalculationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT templateid_fkey FOREIGN KEY (locationtemplatedurationcalculationworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT worktype_fkey FOREIGN KEY (locationtemplatedurationcalculationworktypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX fki_calculationtypeid_fkey ON public.locationtemplatedurationcalculation USING btree (locationtemplatedurationcalculationcalculationtypeid);
CREATE INDEX fki_customerid_fkey ON public.locationtemplatedurationcalculation USING btree (locationtemplatedurationcalculationcustomerid);
CREATE INDEX fki_locationid_fkey ON public.locationtemplatedurationcalculation USING btree (locationtemplatedurationcalculationlocationid);
CREATE INDEX fki_siteid_fkey ON public.locationtemplatedurationcalculation USING btree (locationtemplatedurationcalculationsiteid);
CREATE INDEX fki_worktemplate_fkey ON public.locationtemplatedurationcalculation USING btree (locationtemplatedurationcalculationworktemplateid);
CREATE INDEX fki_worktypeid_fkey ON public.locationtemplatedurationcalculation USING btree (locationtemplatedurationcalculationworktypeid);

GRANT INSERT ON locationtemplatedurationcalculation TO authenticated;
GRANT SELECT ON locationtemplatedurationcalculation TO authenticated;
GRANT UPDATE ON locationtemplatedurationcalculation TO authenticated;
GRANT DELETE ON locationtemplatedurationcalculation TO graphql;
GRANT INSERT ON locationtemplatedurationcalculation TO graphql;
GRANT REFERENCES ON locationtemplatedurationcalculation TO graphql;
GRANT SELECT ON locationtemplatedurationcalculation TO graphql;
GRANT TRIGGER ON locationtemplatedurationcalculation TO graphql;
GRANT TRUNCATE ON locationtemplatedurationcalculation TO graphql;
GRANT UPDATE ON locationtemplatedurationcalculation TO graphql;

-- Type: SEQUENCE ; Name: locationtemplatedurationcalcu_locationtemplatedurationcalcu_seq; Owner: tendreladmin

ALTER TABLE locationtemplatedurationcalculation ALTER locationtemplatedurationcalculationid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: registereddevice_registereddeviceid_seq; Owner: tendreladmin

CREATE SEQUENCE registereddevice_registereddeviceid_seq;


ALTER SEQUENCE registereddevice_registereddeviceid_seq
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 9223372036854775807
 START WITH 1
 NO CYCLE;

-- Type: TABLE ; Name: resource; Owner: tendreladmin

CREATE TABLE resource (
    resourceid bigint GENERATED ALWAYS AS IDENTITY,
    resourcecustomerid bigint NOT NULL,
    resourcescanid text,
    resourcelookupname text,
    resourcetypeid bigint NOT NULL,
    resourcecustomertypeid bigint NOT NULL,
    resourcecreateddate timestamp(3) with time zone,
    resourcemodifieddate timestamp(3) with time zone,
    resourcestartdate timestamp(3) with time zone,
    resourceenddate timestamp(3) with time zone,
    resourcesiteid bigint NOT NULL,
    resourceexternalsystemid bigint,
    resourceexternalid text,
    resourcenameid bigint NOT NULL,
    resourceneedstranslation boolean NOT NULL,
    resourceorder integer NOT NULL,
    resourceuuid text NOT NULL,
    resourcemodifiedby bigint,
    resourcerefid bigint,
    resourcerefuuid text
);


ALTER TABLE resource ALTER resourcecreateddate SET DEFAULT now();
ALTER TABLE resource ALTER resourcemodifieddate SET DEFAULT now();
ALTER TABLE resource ALTER resourcestartdate SET DEFAULT now();
ALTER TABLE resource ALTER resourceneedstranslation SET DEFAULT true;
ALTER TABLE resource ALTER resourceorder SET DEFAULT 1;
ALTER TABLE resource ALTER resourceuuid SET DEFAULT concat('resource_', gen_random_uuid());

ALTER TABLE resource ADD CONSTRAINT resource_resourcecustomerid_resourcescanid_key UNIQUE (resourcecustomerid, resourcescanid);
ALTER TABLE resource ADD CONSTRAINT resource_pkey PRIMARY KEY (resourceid);
ALTER TABLE resource ADD CONSTRAINT resource_resourcecustomerid_fkey FOREIGN KEY (resourcecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE resource ADD CONSTRAINT resource_resourcecustomertypeid_fkey FOREIGN KEY (resourcecustomertypeid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE resource ADD CONSTRAINT resource_resourcemodifiedby_fkey FOREIGN KEY (resourcemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE resource ADD CONSTRAINT resource_resourcenameid_fkey FOREIGN KEY (resourcenameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE resource ADD CONSTRAINT resource_resourcesiteid_fkey FOREIGN KEY (resourcesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE resource ADD CONSTRAINT resource_resourcetypeid_fkey FOREIGN KEY (resourcetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX resource_resourcecustomerid_resourcelookupname_resourcesite_key ON public.resource USING btree (resourcecustomerid, resourcelookupname, resourcesiteid);
CREATE UNIQUE INDEX resource_resourceuuid_key ON public.resource USING btree (resourceuuid);

GRANT INSERT ON resource TO authenticated;
GRANT SELECT ON resource TO authenticated;
GRANT UPDATE ON resource TO authenticated;
GRANT DELETE ON resource TO graphql;
GRANT INSERT ON resource TO graphql;
GRANT REFERENCES ON resource TO graphql;
GRANT SELECT ON resource TO graphql;
GRANT TRIGGER ON resource TO graphql;
GRANT TRUNCATE ON resource TO graphql;
GRANT UPDATE ON resource TO graphql;

-- Type: SEQUENCE ; Name: resource_resourceid_seq; Owner: tendreladmin

ALTER TABLE resource ALTER resourceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: systag; Owner: tendreladmin

CREATE TABLE systag (
    systagid bigint GENERATED ALWAYS AS IDENTITY,
    systagcustomerid bigint NOT NULL,
    systagparentid bigint NOT NULL,
    systagcreateddate timestamp(3) with time zone NOT NULL,
    systagmodifieddate timestamp(3) with time zone NOT NULL,
    systagstartdate timestamp(3) with time zone,
    systagenddate timestamp(3) with time zone,
    systagorder bigint NOT NULL,
    systagnameid bigint NOT NULL,
    systagabbreviationid bigint,
    systagtype text NOT NULL,
    systagexternalid text,
    systagexternalsystemid bigint,
    systagmodifiedby bigint,
    systagrefid bigint,
    systagrefuuid text,
    systaguuid text NOT NULL
);


ALTER TABLE systag ALTER systagcustomerid SET DEFAULT 0;
ALTER TABLE systag ALTER systagcreateddate SET DEFAULT now();
ALTER TABLE systag ALTER systagmodifieddate SET DEFAULT now();
ALTER TABLE systag ALTER systagstartdate SET DEFAULT now();
ALTER TABLE systag ALTER systagorder SET DEFAULT 1;
ALTER TABLE systag ALTER systaguuid SET DEFAULT concat('systag_', gen_random_uuid());

ALTER TABLE systag ADD CONSTRAINT systag_pkey PRIMARY KEY (systagid);
ALTER TABLE systag ADD CONSTRAINT systag_systagabbreviationid_fkey FOREIGN KEY (systagabbreviationid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE systag ADD CONSTRAINT systag_systagmodifiedby_fkey FOREIGN KEY (systagmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE systag ADD CONSTRAINT systag_systagnameid_fkey FOREIGN KEY (systagnameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX systag_systagparentid_systagtype_key ON public.systag USING btree (systagparentid, systagtype);
CREATE UNIQUE INDEX systag_systaguuid_key ON public.systag USING btree (systaguuid);

GRANT INSERT ON systag TO authenticated;
GRANT SELECT ON systag TO authenticated;
GRANT UPDATE ON systag TO authenticated;
GRANT DELETE ON systag TO graphql;
GRANT INSERT ON systag TO graphql;
GRANT REFERENCES ON systag TO graphql;
GRANT SELECT ON systag TO graphql;
GRANT TRIGGER ON systag TO graphql;
GRANT TRUNCATE ON systag TO graphql;
GRANT UPDATE ON systag TO graphql;

-- Type: SEQUENCE ; Name: tag_tagid_seq; Owner: tendreladmin

ALTER TABLE systag ALTER systagid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: user; Owner: tendreladmin

CREATE TABLE "user" (
    userid text NOT NULL,
    usercreateddate timestamp(3) with time zone NOT NULL,
    usermodifieddate timestamp(3) with time zone NOT NULL,
    usercustomerid bigint,
    userfirstname text,
    userlastname text,
    useremail text,
    useraddressid bigint,
    userstartdate timestamp(3) with time zone,
    userenddate timestamp(3) with time zone,
    userfullname text,
    userlanguageid bigint,
    userisadmin boolean,
    userusername text,
    userpassword text,
    userphonenumber text
);


ALTER TABLE "user" ALTER usercreateddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "user" ALTER usermodifieddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "user" ALTER userstartdate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "user" ALTER userisadmin SET DEFAULT false;

ALTER TABLE "user" ADD CONSTRAINT user_pkey PRIMARY KEY (userid);
ALTER TABLE "user" ADD CONSTRAINT addressid_fkey FOREIGN KEY (useraddressid) REFERENCES address(addressid);
ALTER TABLE "user" ADD CONSTRAINT customerid_fkey FOREIGN KEY (usercustomerid) REFERENCES customer(customerid);
ALTER TABLE "user" ADD CONSTRAINT languageid_fkey FOREIGN KEY (userlanguageid) REFERENCES systag(systagid);

GRANT INSERT ON "user" TO authenticated;
GRANT SELECT ON "user" TO authenticated;
GRANT UPDATE ON "user" TO authenticated;
GRANT DELETE ON "user" TO graphql;
GRANT INSERT ON "user" TO graphql;
GRANT REFERENCES ON "user" TO graphql;
GRANT SELECT ON "user" TO graphql;
GRANT TRIGGER ON "user" TO graphql;
GRANT TRUNCATE ON "user" TO graphql;
GRANT UPDATE ON "user" TO graphql;

-- Type: TABLE ; Name: workdescription; Owner: tendreladmin

CREATE TABLE workdescription (
    workdescriptionid bigint GENERATED ALWAYS AS IDENTITY,
    workdescriptionworktemplateid bigint NOT NULL,
    workdescriptioncustomerid bigint NOT NULL,
    workdescriptionname text,
    workdescriptionsoplink text,
    workdescriptioncreateddate timestamp(3) with time zone NOT NULL,
    workdescriptionmodifieddate timestamp(3) with time zone NOT NULL,
    workdescriptionstartdate timestamp(3) with time zone,
    workdescriptionenddate timestamp(3) with time zone,
    workdescriptionlanguagemasterid bigint NOT NULL,
    workdescriptionlanguagetypeid bigint NOT NULL,
    workdescriptionneedstranslation boolean NOT NULL,
    workdescriptionexternalid text,
    workdescriptionexternalsystemid bigint,
    workdescriptionmodifiedby bigint,
    workdescriptionrefid bigint,
    workdescriptiondeleted boolean NOT NULL,
    workdescriptiondraft boolean NOT NULL,
    workdescriptionfile text,
    workdescriptionicon text,
    workdescriptionworkresultid bigint,
    id text NOT NULL,
    workdescriptionmimetypeid bigint
);


ALTER TABLE workdescription ALTER workdescriptioncreateddate SET DEFAULT now();
ALTER TABLE workdescription ALTER workdescriptionmodifieddate SET DEFAULT now();
ALTER TABLE workdescription ALTER workdescriptionstartdate SET DEFAULT now();
ALTER TABLE workdescription ALTER workdescriptionneedstranslation SET DEFAULT true;
ALTER TABLE workdescription ALTER workdescriptiondeleted SET DEFAULT false;
ALTER TABLE workdescription ALTER workdescriptiondraft SET DEFAULT false;
ALTER TABLE workdescription ALTER id SET DEFAULT gen_random_uuid();

ALTER TABLE workdescription ADD CONSTRAINT workdescription_pkey PRIMARY KEY (workdescriptionid);
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptioncustomerid_fkey FOREIGN KEY (workdescriptioncustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionlanguagemasterid_fkey FOREIGN KEY (workdescriptionlanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionlanguagetypeid_fkey FOREIGN KEY (workdescriptionlanguagetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionmimetypeid_fkey FOREIGN KEY (workdescriptionmimetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionmodifiedby_fkey FOREIGN KEY (workdescriptionmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionworkresultid_fkey FOREIGN KEY (workdescriptionworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionworktemplateid_fkey FOREIGN KEY (workdescriptionworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX workdescription_id_key ON public.workdescription USING btree (id);
CREATE INDEX workdescription_workdescriptiondeleted_idx ON public.workdescription USING btree (workdescriptiondeleted);
CREATE INDEX workdescription_workdescriptiondraft_idx ON public.workdescription USING btree (workdescriptiondraft);

GRANT INSERT ON workdescription TO authenticated;
GRANT SELECT ON workdescription TO authenticated;
GRANT UPDATE ON workdescription TO authenticated;
GRANT DELETE ON workdescription TO graphql;
GRANT INSERT ON workdescription TO graphql;
GRANT REFERENCES ON workdescription TO graphql;
GRANT SELECT ON workdescription TO graphql;
GRANT TRIGGER ON workdescription TO graphql;
GRANT TRUNCATE ON workdescription TO graphql;
GRANT UPDATE ON workdescription TO graphql;

-- Type: TABLE ; Name: worker; Owner: tendreladmin

CREATE TABLE worker (
    workerid bigint GENERATED ALWAYS AS IDENTITY,
    workerfirstname text NOT NULL,
    workerlastname text NOT NULL,
    workeremail text,
    workeraddressid bigint,
    workerstartdate timestamp(3) with time zone,
    workerenddate timestamp(3) with time zone,
    workerfullname text,
    workerlanguageid bigint NOT NULL,
    workercreateddate timestamp(3) with time zone NOT NULL,
    workermodifieddate timestamp(3) with time zone NOT NULL,
    workerusername text,
    workerpassword text,
    workerphonenumber text,
    workerrefid bigint,
    workerexternalid text,
    workerexternalsystemid bigint,
    workermodifiedby bigint,
    workerdatacomplete boolean NOT NULL,
    workeruuid text NOT NULL,
    workerexternalsystemuuid text,
    workeridentityid text,
    workeridentitysystemid bigint,
    workeridentitysystemuuid text,
    workergeneratedname text NOT NULL GENERATED ALWAYS AS (
CASE
    WHEN (workerfirstname IS NULL) THEN workerlastname
    WHEN (workerlastname IS NULL) THEN workerfirstname
    WHEN ((workerfirstname IS NULL) AND (workerlastname IS NULL)) THEN workerfullname
    ELSE ((workerfirstname || ' '::text) || workerlastname)
END) STORED
);


ALTER TABLE worker ALTER workerstartdate SET DEFAULT now();
ALTER TABLE worker ALTER workercreateddate SET DEFAULT now();
ALTER TABLE worker ALTER workermodifieddate SET DEFAULT now();
ALTER TABLE worker ALTER workerdatacomplete SET DEFAULT true;
ALTER TABLE worker ALTER workeruuid SET DEFAULT concat('worker_', gen_random_uuid());

ALTER TABLE worker ADD CONSTRAINT worker_workerusername_key UNIQUE (workerusername);
ALTER TABLE worker ADD CONSTRAINT worker_pkey PRIMARY KEY (workerid);
ALTER TABLE worker ADD CONSTRAINT worker_workeraddressid_fkey FOREIGN KEY (workeraddressid) REFERENCES address(addressid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worker ADD CONSTRAINT worker_workerexternalsystemuuid_fkey FOREIGN KEY (workerexternalsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worker ADD CONSTRAINT worker_workeridentitysystemid_fkey FOREIGN KEY (workeridentitysystemid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worker ADD CONSTRAINT worker_workeridentitysystemuuid_fkey FOREIGN KEY (workeridentitysystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worker ADD CONSTRAINT worker_workerlanguageid_fkey FOREIGN KEY (workerlanguageid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worker ADD CONSTRAINT worker_workermodifiedby_fkey FOREIGN KEY (workermodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

CREATE UNIQUE INDEX worker_workeridentityid_key ON public.worker USING btree (workeridentityid);
CREATE UNIQUE INDEX worker_workeruuid_key ON public.worker USING btree (workeruuid);

GRANT INSERT ON worker TO authenticated;
GRANT SELECT ON worker TO authenticated;
GRANT UPDATE ON worker TO authenticated;
GRANT DELETE ON worker TO graphql;
GRANT INSERT ON worker TO graphql;
GRANT REFERENCES ON worker TO graphql;
GRANT SELECT ON worker TO graphql;
GRANT TRIGGER ON worker TO graphql;
GRANT TRUNCATE ON worker TO graphql;
GRANT UPDATE ON worker TO graphql;

-- Type: TABLE ; Name: workerinstance; Owner: tendreladmin

CREATE TABLE workerinstance (
    workerinstanceid bigint GENERATED ALWAYS AS IDENTITY,
    workerinstanceworkerid bigint NOT NULL,
    workerinstancecustomerid bigint NOT NULL,
    workerinstancestartdate timestamp(3) with time zone,
    workerinstanceenddate timestamp(3) with time zone,
    workerinstancelanguageid bigint NOT NULL,
    workerinstancecreateddate timestamp(3) with time zone NOT NULL,
    workerinstancemodifieddate timestamp(3) with time zone NOT NULL,
    workerinstanceexternalsystemid bigint,
    workerinstanceexternalid text,
    workerinstancescanid text,
    workerinstanceuserroleid bigint NOT NULL,
    workerinstancemodifiedby bigint,
    workerinstancerefid bigint,
    workerinstanceuuid text NOT NULL,
    workerinstancedatacomplete boolean NOT NULL,
    workerinstancecustomeruuid text,
    workerinstanceworkeruuid text,
    workerinstancelanguageuuid text,
    workerinstanceuserroleuuid text,
    workerinstanceexternalsystemuuid text,
    workerinstancesiteid bigint
);


ALTER TABLE workerinstance ALTER workerinstancestartdate SET DEFAULT now();
ALTER TABLE workerinstance ALTER workerinstancecreateddate SET DEFAULT now();
ALTER TABLE workerinstance ALTER workerinstancemodifieddate SET DEFAULT now();
ALTER TABLE workerinstance ALTER workerinstanceuuid SET DEFAULT concat('worker-instance_', gen_random_uuid());
ALTER TABLE workerinstance ALTER workerinstancedatacomplete SET DEFAULT true;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_pkey PRIMARY KEY (workerinstanceid);
ALTER TABLE workerinstance ADD CONSTRAINT customerid_fkey FOREIGN KEY (workerinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancecustomeruuid_fkey FOREIGN KEY (workerinstancecustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceexternalsystemid_fkey FOREIGN KEY (workerinstanceexternalsystemid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceexternalsystemuuid_fkey FOREIGN KEY (workerinstanceexternalsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancelanguageid_fkey FOREIGN KEY (workerinstancelanguageid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancelanguageuuid_fkey FOREIGN KEY (workerinstancelanguageuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancesiteid_fkey FOREIGN KEY (workerinstancesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceuserroleid_fkey FOREIGN KEY (workerinstanceuserroleid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceuserroleuuid_fkey FOREIGN KEY (workerinstanceuserroleuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceworkerid_fkey FOREIGN KEY (workerinstanceworkerid) REFERENCES worker(workerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceworkeruuid_fkey FOREIGN KEY (workerinstanceworkeruuid) REFERENCES worker(workeruuid) ON UPDATE CASCADE ON DELETE SET NULL;

CREATE UNIQUE INDEX workerinstance_workerinstancecustomerid_workerinstanceworke_key ON public.workerinstance USING btree (workerinstancecustomerid, workerinstanceworkerid);
CREATE UNIQUE INDEX workerinstance_workerinstanceuuid_key ON public.workerinstance USING btree (workerinstanceuuid);

GRANT INSERT ON workerinstance TO authenticated;
GRANT SELECT ON workerinstance TO authenticated;
GRANT UPDATE ON workerinstance TO authenticated;
GRANT DELETE ON workerinstance TO graphql;
GRANT INSERT ON workerinstance TO graphql;
GRANT REFERENCES ON workerinstance TO graphql;
GRANT SELECT ON workerinstance TO graphql;
GRANT TRIGGER ON workerinstance TO graphql;
GRANT TRUNCATE ON workerinstance TO graphql;
GRANT UPDATE ON workerinstance TO graphql;

-- Type: TABLE ; Name: workfrequency; Owner: tendreladmin

CREATE TABLE workfrequency (
    workfrequencyid bigint GENERATED ALWAYS AS IDENTITY,
    workfrequencycustomerid bigint NOT NULL,
    workfrequencyworktemplateid bigint NOT NULL,
    workfrequencytypeid bigint NOT NULL,
    workfrequencyvalue numeric NOT NULL,
    workfrequencystartdate timestamp(3) with time zone,
    workfrequencyenddate timestamp(3) with time zone,
    workfrequencycreateddate timestamp(3) with time zone NOT NULL,
    workfrequencymodifieddate timestamp(3) with time zone NOT NULL,
    workfrequencyexternalid text,
    workfrequencyexternalsystemid bigint,
    workfrequencymodifiedby bigint,
    workfrequencyrefid bigint
);


ALTER TABLE workfrequency ALTER workfrequencycreateddate SET DEFAULT now();
ALTER TABLE workfrequency ALTER workfrequencymodifieddate SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_pkey PRIMARY KEY (workfrequencyid);
ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_workfrequencycustomerid_fkey FOREIGN KEY (workfrequencycustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_workfrequencymodifiedby_fkey FOREIGN KEY (workfrequencymodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_workfrequencytypeid_fkey FOREIGN KEY (workfrequencytypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

GRANT INSERT ON workfrequency TO authenticated;
GRANT SELECT ON workfrequency TO authenticated;
GRANT UPDATE ON workfrequency TO authenticated;
GRANT DELETE ON workfrequency TO graphql;
GRANT INSERT ON workfrequency TO graphql;
GRANT REFERENCES ON workfrequency TO graphql;
GRANT SELECT ON workfrequency TO graphql;
GRANT TRIGGER ON workfrequency TO graphql;
GRANT TRUNCATE ON workfrequency TO graphql;
GRANT UPDATE ON workfrequency TO graphql;

-- Type: TABLE ; Name: workresult; Owner: tendreladmin

CREATE TABLE workresult (
    workresultid bigint GENERATED ALWAYS AS IDENTITY,
    workresultworktemplateid bigint NOT NULL,
    workresultcustomerid bigint NOT NULL,
    workresulttypeid bigint NOT NULL,
    workresultforaudit boolean NOT NULL,
    workresultcreateddate timestamp(3) without time zone NOT NULL,
    workresultmodifieddate timestamp(3) with time zone,
    workresultstartdate timestamp(3) with time zone,
    workresultenddate timestamp(3) with time zone,
    workresultsoplink text,
    workresultlanguagemasterid bigint NOT NULL,
    workresultsiteid bigint NOT NULL,
    workresultorder bigint NOT NULL,
    id text NOT NULL,
    workresultdefaultvalue text,
    workresultiscalculated boolean NOT NULL,
    workresultiseditable boolean NOT NULL,
    workresultisvisible boolean NOT NULL,
    workresultisrequired boolean NOT NULL,
    workresultfortask boolean NOT NULL,
    workresultentitytypeid bigint,
    workresultformatid bigint,
    workresultwidgetid bigint,
    workresultexternalid text,
    workresultexternalsystemid bigint,
    workresultmodifiedby bigint,
    workresultrefid bigint,
    workresultrefuuid text,
    workresultisprimary boolean NOT NULL,
    workresulttranslate boolean NOT NULL,
    workresultdeleted boolean NOT NULL,
    workresultdraft boolean NOT NULL
);


ALTER TABLE workresult ALTER workresultcreateddate SET DEFAULT now();
ALTER TABLE workresult ALTER workresultmodifieddate SET DEFAULT now();
ALTER TABLE workresult ALTER workresultstartdate SET DEFAULT now();
ALTER TABLE workresult ALTER id SET DEFAULT concat('work-result_', gen_random_uuid());
ALTER TABLE workresult ALTER workresultiscalculated SET DEFAULT false;
ALTER TABLE workresult ALTER workresultiseditable SET DEFAULT true;
ALTER TABLE workresult ALTER workresultisvisible SET DEFAULT true;
ALTER TABLE workresult ALTER workresultisrequired SET DEFAULT false;
ALTER TABLE workresult ALTER workresultisprimary SET DEFAULT false;
ALTER TABLE workresult ALTER workresulttranslate SET DEFAULT true;
ALTER TABLE workresult ALTER workresultdeleted SET DEFAULT false;
ALTER TABLE workresult ALTER workresultdraft SET DEFAULT false;

ALTER TABLE workresult ADD CONSTRAINT workresult_pkey PRIMARY KEY (workresultid);
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultcustomerid_fkey FOREIGN KEY (workresultcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultentitytypeid_fkey FOREIGN KEY (workresultentitytypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultformatid_fkey FOREIGN KEY (workresultformatid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultlanguagemasterid_fkey FOREIGN KEY (workresultlanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultmodifiedby_fkey FOREIGN KEY (workresultmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultsiteid_fkey FOREIGN KEY (workresultsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresulttypeid_fkey FOREIGN KEY (workresulttypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultwidgetid_fkey FOREIGN KEY (workresultwidgetid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresult ADD CONSTRAINT workresult_workresultworktemplateid_fkey FOREIGN KEY (workresultworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX workresult_id_key ON public.workresult USING btree (id);
CREATE INDEX workresult_templatecustomerforauditenddate_idx ON public.workresult USING btree (workresultworktemplateid, workresultcustomerid, workresultforaudit, workresultenddate);
CREATE INDEX workresult_workresultcustomerid_idx ON public.workresult USING btree (workresultcustomerid);
CREATE INDEX workresult_workresultdeleted_idx ON public.workresult USING btree (workresultdeleted);
CREATE INDEX workresult_workresultdraft_idx ON public.workresult USING btree (workresultdraft);
CREATE INDEX workresult_workresultid_entity_primary_idx ON public.workresult USING btree (workresultid, workresultentitytypeid, workresultisprimary);
CREATE INDEX workresult_workresultid_type_entity_primary_idx ON public.workresult USING btree (workresultid, workresulttypeid, workresultentitytypeid, workresultisprimary);
CREATE INDEX workresult_workresultlanguagemasterid_idx ON public.workresult USING btree (workresultlanguagemasterid);
CREATE INDEX workresult_workresulttypeid_idx ON public.workresult USING btree (workresulttypeid);
CREATE INDEX workresult_workresultworktemplateid_workresulttypeid_workre_idx ON public.workresult USING btree (workresultworktemplateid, workresulttypeid, workresultentitytypeid, workresultisprimary);

GRANT INSERT ON workresult TO authenticated;
GRANT SELECT ON workresult TO authenticated;
GRANT UPDATE ON workresult TO authenticated;
GRANT DELETE ON workresult TO graphql;
GRANT INSERT ON workresult TO graphql;
GRANT REFERENCES ON workresult TO graphql;
GRANT SELECT ON workresult TO graphql;
GRANT TRIGGER ON workresult TO graphql;
GRANT TRUNCATE ON workresult TO graphql;
GRANT UPDATE ON workresult TO graphql;

-- Type: TABLE ; Name: workresource; Owner: tendreladmin

CREATE TABLE workresource (
    workresourceid bigint GENERATED ALWAYS AS IDENTITY,
    workresourceworktemplateid bigint,
    workresourcecustomerid bigint NOT NULL,
    workresourceresourcetasktypeid bigint,
    workresourceresourcetypeid bigint NOT NULL,
    workresourcestartdate timestamp(3) with time zone,
    workresourceenddate timestamp(3) with time zone,
    workresourcecreateddate timestamp(3) with time zone NOT NULL,
    workresourcemodifieddate timestamp(3) with time zone NOT NULL,
    workresourceresourcecustomertypeid bigint,
    workresourceexternalid text,
    workresourceexternalsystemid bigint,
    workresourcemodifiedby bigint,
    workresourcerefid bigint
);


ALTER TABLE workresource ALTER workresourcestartdate SET DEFAULT now();
ALTER TABLE workresource ALTER workresourcecreateddate SET DEFAULT now();
ALTER TABLE workresource ALTER workresourcemodifieddate SET DEFAULT now();

ALTER TABLE workresource ADD CONSTRAINT workresource_pkey PRIMARY KEY (workresourceid);
ALTER TABLE workresource ADD CONSTRAINT workresource_workresourcecustomerid_fkey FOREIGN KEY (workresourcecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresource ADD CONSTRAINT workresource_workresourcemodifiedby_fkey FOREIGN KEY (workresourcemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresource ADD CONSTRAINT workresource_workresourceresourcecustomertypeid_fkey FOREIGN KEY (workresourceresourcecustomertypeid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresource ADD CONSTRAINT workresource_workresourceresourcetypeid_fkey FOREIGN KEY (workresourceresourcetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresource ADD CONSTRAINT workresource_workresourceworktemplateid_fkey FOREIGN KEY (workresourceworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE SET NULL;

GRANT INSERT ON workresource TO authenticated;
GRANT SELECT ON workresource TO authenticated;
GRANT UPDATE ON workresource TO authenticated;
GRANT DELETE ON workresource TO graphql;
GRANT INSERT ON workresource TO graphql;
GRANT REFERENCES ON workresource TO graphql;
GRANT SELECT ON workresource TO graphql;
GRANT TRIGGER ON workresource TO graphql;
GRANT TRUNCATE ON workresource TO graphql;
GRANT UPDATE ON workresource TO graphql;

-- Type: TABLE ; Name: worktemplatenexttemplate; Owner: tendreladmin

CREATE TABLE worktemplatenexttemplate (
    worktemplatenexttemplateid bigint GENERATED ALWAYS AS IDENTITY,
    worktemplatenexttemplateprevioustemplateid bigint NOT NULL,
    worktemplatenexttemplatenexttemplateid bigint NOT NULL,
    worktemplatenexttemplatecustomerid bigint NOT NULL,
    worktemplatenexttemplateviastatuschange boolean,
    worktemplatenexttemplateviastatuschangeid bigint,
    worktemplatenexttemplateviaworkresultid bigint,
    worktemplatenexttemplateviaworkresultvalue text,
    worktemplatenexttemplatestartdate timestamp(3) with time zone,
    worktemplatenexttemplateenddate timestamp(3) with time zone,
    worktemplatenexttemplatecreateddate timestamp(3) with time zone NOT NULL,
    worktemplatenexttemplatemodifieddate timestamp(3) with time zone NOT NULL,
    worktemplatenexttemplatesiteid bigint NOT NULL,
    worktemplatenexttemplateviaworkresultcontstraintid bigint,
    worktemplatenexttemplatetypeid bigint NOT NULL,
    worktemplatenexttemplateexternalid text,
    worktemplatenexttemplateexternalsystemid bigint,
    worktemplatenexttemplatemodifiedby bigint,
    worktemplatenexttemplaterefid bigint,
    worktemplatenexttemplateuuid text NOT NULL,
    worktemplatenexttemplateprevlocationid text,
    worktemplatenexttemplatenextlocationid text
);


ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplatestartdate SET DEFAULT now();
ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplatecreateddate SET DEFAULT now();
ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplatemodifieddate SET DEFAULT now();
ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplatetypeid SET DEFAULT 692;
ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplateuuid SET DEFAULT gen_random_uuid();

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateuuid_key UNIQUE (worktemplatenexttemplateuuid);
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_pkey PRIMARY KEY (worktemplatenexttemplateid);
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT constraintid_fkey FOREIGN KEY (worktemplatenexttemplateviaworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatecustomeri_fkey FOREIGN KEY (worktemplatenexttemplatecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatemodifiedb_fkey FOREIGN KEY (worktemplatenexttemplatemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatenextlocat_fkey FOREIGN KEY (worktemplatenexttemplatenextlocationid) REFERENCES location(locationuuid);
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatenexttempl_fkey FOREIGN KEY (worktemplatenexttemplatenexttemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateprevioust_fkey FOREIGN KEY (worktemplatenexttemplateprevioustemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateprevlocat_fkey FOREIGN KEY (worktemplatenexttemplateprevlocationid) REFERENCES location(locationuuid);
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatesiteid_fkey FOREIGN KEY (worktemplatenexttemplatesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatetypeid_fkey FOREIGN KEY (worktemplatenexttemplatetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateviastatus_fkey FOREIGN KEY (worktemplatenexttemplateviastatuschangeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateviaworkre_fkey FOREIGN KEY (worktemplatenexttemplateviaworkresultcontstraintid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

GRANT INSERT ON worktemplatenexttemplate TO authenticated;
GRANT SELECT ON worktemplatenexttemplate TO authenticated;
GRANT UPDATE ON worktemplatenexttemplate TO authenticated;
GRANT DELETE ON worktemplatenexttemplate TO graphql;
GRANT INSERT ON worktemplatenexttemplate TO graphql;
GRANT REFERENCES ON worktemplatenexttemplate TO graphql;
GRANT SELECT ON worktemplatenexttemplate TO graphql;
GRANT TRIGGER ON worktemplatenexttemplate TO graphql;
GRANT TRUNCATE ON worktemplatenexttemplate TO graphql;
GRANT UPDATE ON worktemplatenexttemplate TO graphql;

-- Type: TABLE ; Name: workresultcalculated; Owner: tendreladmin

CREATE TABLE workresultcalculated (
    workresultcalculatedid bigint GENERATED ALWAYS AS IDENTITY,
    workresultcalculatedcustomerid bigint NOT NULL,
    workresultcalculatedworkresultid bigint NOT NULL,
    workresultcalculatedfirstworkresultid bigint NOT NULL,
    workresultcalculatedsecondworkresultid bigint NOT NULL,
    workresultcalculatedcalculationid bigint NOT NULL,
    workresultcalculatedcalcualtionidcalcualtionname text,
    workresultcalculatedstartdate timestamp(3) with time zone,
    workresultcalculatedenddate timestamp(3) with time zone,
    workresultcalculatedcreateddate timestamp(3) with time zone NOT NULL,
    workresultcalculatedmodifieddate timestamp(3) with time zone NOT NULL,
    workresultcalculatedsiteid bigint NOT NULL,
    workresultcalculatedexternalid text,
    workresultcalculatedexternalsystemid bigint,
    workresultcalculatedmodifiedby bigint,
    workresultcalculatedrefid bigint
);


ALTER TABLE workresultcalculated ALTER workresultcalculatedstartdate SET DEFAULT now();
ALTER TABLE workresultcalculated ALTER workresultcalculatedcreateddate SET DEFAULT now();
ALTER TABLE workresultcalculated ALTER workresultcalculatedmodifieddate SET DEFAULT now();

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_pkey PRIMARY KEY (workresultcalculatedid);
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedcalculationid_fkey FOREIGN KEY (workresultcalculatedcalculationid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedcustomerid_fkey FOREIGN KEY (workresultcalculatedcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedfirstworkresultid_fkey FOREIGN KEY (workresultcalculatedfirstworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedmodifiedby_fkey FOREIGN KEY (workresultcalculatedmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedsecondworkresulti_fkey FOREIGN KEY (workresultcalculatedsecondworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedsiteid_fkey FOREIGN KEY (workresultcalculatedsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedworkresultid_fkey FOREIGN KEY (workresultcalculatedworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX workresultcalculated_workresultcalculatedworkresultid_idx ON public.workresultcalculated USING btree (workresultcalculatedworkresultid);

GRANT INSERT ON workresultcalculated TO authenticated;
GRANT SELECT ON workresultcalculated TO authenticated;
GRANT UPDATE ON workresultcalculated TO authenticated;
GRANT DELETE ON workresultcalculated TO graphql;
GRANT INSERT ON workresultcalculated TO graphql;
GRANT REFERENCES ON workresultcalculated TO graphql;
GRANT SELECT ON workresultcalculated TO graphql;
GRANT TRIGGER ON workresultcalculated TO graphql;
GRANT TRUNCATE ON workresultcalculated TO graphql;
GRANT UPDATE ON workresultcalculated TO graphql;

-- Type: TABLE ; Name: worktemplatetype; Owner: tendreladmin

CREATE TABLE worktemplatetype (
    worktemplatetypeuuid text NOT NULL,
    worktemplatetypestartdate timestamp(3) without time zone NOT NULL,
    worktemplatetypeenddate timestamp(3) without time zone,
    worktemplatetypecreateddate timestamp(3) without time zone NOT NULL,
    worktemplatetypemodifieddate timestamp(3) without time zone NOT NULL,
    worktemplatetypemodifiedby bigint,
    worktemplatetyperefid bigint,
    worktemplatetyperefuuid text,
    worktemplatetypeworktemplateuuid text NOT NULL,
    worktemplatetypesystaguuid text NOT NULL,
    worktemplatetypeworktemplateid bigint NOT NULL,
    worktemplatetypesystagid bigint NOT NULL,
    worktemplatetypecustomerid bigint,
    worktemplatetypecustomeruuid text
);


ALTER TABLE worktemplatetype ALTER worktemplatetypeuuid SET DEFAULT concat('work-template-type_', gen_random_uuid());
ALTER TABLE worktemplatetype ALTER worktemplatetypestartdate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE worktemplatetype ALTER worktemplatetypecreateddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE worktemplatetype ALTER worktemplatetypemodifieddate SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_pkey PRIMARY KEY (worktemplatetypeuuid);
ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypecustomerid_fkey FOREIGN KEY (worktemplatetypecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypecustomeruuid_fkey FOREIGN KEY (worktemplatetypecustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypemodifiedby_fkey FOREIGN KEY (worktemplatetypemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypesystaguuid_fkey FOREIGN KEY (worktemplatetypesystaguuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypeworktemplateuuid_fkey FOREIGN KEY (worktemplatetypeworktemplateuuid) REFERENCES worktemplate(id) ON UPDATE CASCADE ON DELETE RESTRICT;

GRANT INSERT ON worktemplatetype TO authenticated;
GRANT SELECT ON worktemplatetype TO authenticated;
GRANT UPDATE ON worktemplatetype TO authenticated;
GRANT DELETE ON worktemplatetype TO graphql;
GRANT INSERT ON worktemplatetype TO graphql;
GRANT REFERENCES ON worktemplatetype TO graphql;
GRANT SELECT ON worktemplatetype TO graphql;
GRANT TRIGGER ON worktemplatetype TO graphql;
GRANT TRUNCATE ON worktemplatetype TO graphql;
GRANT UPDATE ON worktemplatetype TO graphql;

-- Type: SEQUENCE ; Name: workdescription_workdescriptionid_seq; Owner: tendreladmin

ALTER TABLE workdescription ALTER workdescriptionid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: worker_workerid_seq; Owner: tendreladmin

ALTER TABLE worker ALTER workerid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: workerinstance_workerinstanceid_seq; Owner: tendreladmin

ALTER TABLE workerinstance ALTER workerinstanceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workertemplatedurationcalculation; Owner: tendreladmin

CREATE TABLE workertemplatedurationcalculation (
    workertemplatedurationcalculationid bigint GENERATED ALWAYS AS IDENTITY,
    workertemplatedurationcalculationcustomerid bigint NOT NULL,
    workertemplatedurationcalculationsiteid bigint NOT NULL,
    workertemplatedurationcalculationworktemplateid bigint NOT NULL,
    workertemplatedurationcalculationworktypeid bigint NOT NULL,
    workertemplatedurationcalculationworkerid bigint NOT NULL,
    workertemplatedurationcalculationcalculationtypeid bigint NOT NULL,
    workertemplatedurationcalculationworkcount bigint,
    workertemplatedurationcalculationp99 numeric,
    workertemplatedurationcalculationp90 numeric,
    workertemplatedurationcalculationp75 numeric,
    workertemplatedurationcalculationp66 numeric,
    workertemplatedurationcalculationp50 numeric,
    workertemplatedurationcalculationp25 numeric,
    workertemplatedurationcalculationp10 numeric,
    workertemplatedurationcalculationp1 numeric,
    workertemplatedurationcalculationmode numeric,
    workertemplatedurationcalculationavg numeric,
    workertemplatedurationcalculationstddevsample numeric,
    workertemplatedurationcalculationstddevpop numeric,
    workertemplatedurationcalculationvarsample numeric,
    workertemplatedurationcalculationvarpop numeric,
    workertemplatedurationcalculationenddate date NOT NULL,
    workertemplatedurationcalculationcreateddate timestamp(3) with time zone NOT NULL,
    workertemplatedurationcalculationmodifieddate timestamp(3) with time zone NOT NULL,
    workertemplatedurationcalculationexternalid text,
    workertemplatedurationcalculationexternalsystemid bigint,
    workertemplatedurationcalculationmodifiedby bigint,
    workertemplatedurationcalculationrefid bigint
);


ALTER TABLE workertemplatedurationcalculation ALTER workertemplatedurationcalculationcreateddate SET DEFAULT now();
ALTER TABLE workertemplatedurationcalculation ALTER workertemplatedurationcalculationmodifieddate SET DEFAULT now();

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT workertemplatedurationcalculation_pkey PRIMARY KEY (workertemplatedurationcalculationid);
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT calcualtiontypeid_fkey FOREIGN KEY (workertemplatedurationcalculationcalculationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT customerid_fkey FOREIGN KEY (workertemplatedurationcalculationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT siteid_fkey FOREIGN KEY (workertemplatedurationcalculationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT workerinstanceid_fkey FOREIGN KEY (workertemplatedurationcalculationworkerid) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT workertemplatedurationcalculation_workertemplatedurationca_fkey FOREIGN KEY (workertemplatedurationcalculationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT worktemplateid_fkey FOREIGN KEY (workertemplatedurationcalculationworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT worktype_fkey FOREIGN KEY (workertemplatedurationcalculationworktypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

GRANT INSERT ON workertemplatedurationcalculation TO authenticated;
GRANT SELECT ON workertemplatedurationcalculation TO authenticated;
GRANT UPDATE ON workertemplatedurationcalculation TO authenticated;
GRANT DELETE ON workertemplatedurationcalculation TO graphql;
GRANT INSERT ON workertemplatedurationcalculation TO graphql;
GRANT REFERENCES ON workertemplatedurationcalculation TO graphql;
GRANT SELECT ON workertemplatedurationcalculation TO graphql;
GRANT TRIGGER ON workertemplatedurationcalculation TO graphql;
GRANT TRUNCATE ON workertemplatedurationcalculation TO graphql;
GRANT UPDATE ON workertemplatedurationcalculation TO graphql;

-- Type: SEQUENCE ; Name: workertemplatedurationcalcula_workertemplatedurationcalcula_seq; Owner: tendreladmin

ALTER TABLE workertemplatedurationcalculation ALTER workertemplatedurationcalculationid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: workfrequency_workfrequencyid_seq; Owner: tendreladmin

ALTER TABLE workfrequency ALTER workfrequencyid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workfrequencyhistory; Owner: tendreladmin

CREATE TABLE workfrequencyhistory (
    workfrequencyhistoryuuid text NOT NULL,
    workfrequencyhistoryworkfrequencyid bigint NOT NULL,
    workfrequencyhistoryworkfrequencycreateddate timestamp(3) with time zone NOT NULL,
    workfrequencyhistoryworkfrequencymodifieddate timestamp(3) with time zone NOT NULL,
    workfrequencyhistoryworkfrequencycustomerid bigint NOT NULL,
    workfrequencyhistoryworkfrequencyenddate timestamp(3) with time zone,
    workfrequencyhistoryworkfrequencystartdate timestamp(3) with time zone,
    workfrequencyhistoryworkfrequencytypeid bigint NOT NULL,
    workfrequencyhistoryworkfrequencyvalue numeric NOT NULL,
    workfrequencyhistoryworkfrequencyworktemplateid bigint NOT NULL,
    workfrequencyhistoryexternalid text,
    workfrequencyhistoryexternalsystemid bigint,
    workfrequencyhistorymodifiedby bigint,
    workfrequencyhistoryrefid bigint,
    workfrequencyhistoryrefuuid text
);


ALTER TABLE workfrequencyhistory ALTER workfrequencyhistoryuuid SET DEFAULT concat('work-frequency-history_', gen_random_uuid());

ALTER TABLE workfrequencyhistory ADD CONSTRAINT workfrequencyhistory_workfrequencyhistorymodifiedby_fkey FOREIGN KEY (workfrequencyhistorymodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workfrequencyhistory ADD CONSTRAINT workfrequencyhistory_workfrequencyhistoryworkfrequencyid_fkey FOREIGN KEY (workfrequencyhistoryworkfrequencyid) REFERENCES workfrequency(workfrequencyid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX workfrequencyhistory_workfrequencyhistoryuuid_key ON public.workfrequencyhistory USING btree (workfrequencyhistoryuuid);

GRANT INSERT ON workfrequencyhistory TO authenticated;
GRANT SELECT ON workfrequencyhistory TO authenticated;
GRANT UPDATE ON workfrequencyhistory TO authenticated;
GRANT DELETE ON workfrequencyhistory TO graphql;
GRANT INSERT ON workfrequencyhistory TO graphql;
GRANT REFERENCES ON workfrequencyhistory TO graphql;
GRANT SELECT ON workfrequencyhistory TO graphql;
GRANT TRIGGER ON workfrequencyhistory TO graphql;
GRANT TRUNCATE ON workfrequencyhistory TO graphql;
GRANT UPDATE ON workfrequencyhistory TO graphql;

-- Type: TABLE ; Name: workicon; Owner: tendreladmin

CREATE TABLE workicon (
    workiconid bigint GENERATED ALWAYS AS IDENTITY,
    workiconworktemplateid bigint NOT NULL,
    workiconcustomerid bigint NOT NULL,
    workiconname character varying,
    workiconlink character varying,
    workiconcreateddate timestamp(3) with time zone NOT NULL,
    workiconmodifieddate timestamp(3) with time zone NOT NULL,
    workiconstartdate timestamp(3) with time zone,
    workiconenddate timestamp(3) with time zone
);


ALTER TABLE workicon ALTER workiconcreateddate SET DEFAULT now();
ALTER TABLE workicon ALTER workiconmodifieddate SET DEFAULT now();
ALTER TABLE workicon ALTER workiconstartdate SET DEFAULT now();

ALTER TABLE workicon ADD CONSTRAINT workicon_pkey PRIMARY KEY (workiconid);
ALTER TABLE workicon ADD CONSTRAINT workicon_workiconcustomerid_fkey FOREIGN KEY (workiconcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workicon ADD CONSTRAINT workicon_workiconworktemplateid_fkey FOREIGN KEY (workiconworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

GRANT INSERT ON workicon TO authenticated;
GRANT SELECT ON workicon TO authenticated;
GRANT UPDATE ON workicon TO authenticated;
GRANT DELETE ON workicon TO graphql;
GRANT INSERT ON workicon TO graphql;
GRANT REFERENCES ON workicon TO graphql;
GRANT SELECT ON workicon TO graphql;
GRANT TRIGGER ON workicon TO graphql;
GRANT TRUNCATE ON workicon TO graphql;
GRANT UPDATE ON workicon TO graphql;

-- Type: SEQUENCE ; Name: workicon_workiconid_seq; Owner: tendreladmin

ALTER TABLE workicon ALTER workiconid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workinstanceexception; Owner: tendreladmin

CREATE TABLE workinstanceexception (
    workinstanceexceptionid bigint GENERATED ALWAYS AS IDENTITY,
    workinstanceexceptioncustomerid bigint NOT NULL,
    workinstanceexceptionworktemplateid bigint NOT NULL,
    workinstanceexceptionsiteid bigint NOT NULL,
    workinstanceexceptionlocationid bigint NOT NULL,
    workinstanceexceptioncreateddate timestamp(3) with time zone NOT NULL,
    workinstanceexceptionmodifieddate timestamp(3) with time zone NOT NULL,
    workinstanceexceptionstartdate timestamp(3) with time zone,
    workinstanceexceptionenddate timestamp(3) with time zone,
    workinstanceexceptionexternalid text,
    workinstanceexceptionexternalsystemid bigint,
    workinstanceexceptionmodifiedby bigint,
    workinstanceexceptionrefid bigint
);


ALTER TABLE workinstanceexception ALTER workinstanceexceptioncreateddate SET DEFAULT now();
ALTER TABLE workinstanceexception ALTER workinstanceexceptionmodifieddate SET DEFAULT now();

ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_pkey PRIMARY KEY (workinstanceexceptionid);
ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptioncustomerid_fkey FOREIGN KEY (workinstanceexceptioncustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionlocationid_fkey FOREIGN KEY (workinstanceexceptionlocationid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionmodifiedby_fkey FOREIGN KEY (workinstanceexceptionmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionsiteid_fkey FOREIGN KEY (workinstanceexceptionsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionworktemplateid_fkey FOREIGN KEY (workinstanceexceptionworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX exception_templatelocationendstart_idx ON public.workinstanceexception USING btree (workinstanceexceptionworktemplateid, workinstanceexceptionlocationid, workinstanceexceptionenddate, workinstanceexceptionstartdate);

GRANT INSERT ON workinstanceexception TO authenticated;
GRANT SELECT ON workinstanceexception TO authenticated;
GRANT UPDATE ON workinstanceexception TO authenticated;
GRANT DELETE ON workinstanceexception TO graphql;
GRANT INSERT ON workinstanceexception TO graphql;
GRANT REFERENCES ON workinstanceexception TO graphql;
GRANT SELECT ON workinstanceexception TO graphql;
GRANT TRIGGER ON workinstanceexception TO graphql;
GRANT TRUNCATE ON workinstanceexception TO graphql;
GRANT UPDATE ON workinstanceexception TO graphql;

-- Type: SEQUENCE ; Name: workinstanceexception_workinstanceexceptionid_seq; Owner: tendreladmin

ALTER TABLE workinstanceexception ALTER workinstanceexceptionid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workpictureinstance; Owner: tendreladmin

CREATE TABLE workpictureinstance (
    workpictureinstanceid bigint GENERATED ALWAYS AS IDENTITY,
    workpictureinstanceworkinstanceid bigint NOT NULL,
    workpictureinstanceworkresultinstanceid bigint,
    workpictureinstancecustomerid bigint NOT NULL,
    workpictureinstancestoragelocation text NOT NULL,
    workpictureinstancecreateddate timestamp(3) with time zone NOT NULL,
    workpictureinstancemodifieddate timestamp(3) with time zone NOT NULL,
    workpictureinstanceexternalid text,
    workpictureinstanceexternalsystemid bigint,
    workpictureinstancemodifiedby bigint,
    workpictureinstancerefid bigint,
    workpictureinstancerefuuid text,
    workpictureinstanceuuid text NOT NULL,
    workpictureinstancemimetypeid bigint
);


ALTER TABLE workpictureinstance ALTER workpictureinstancecreateddate SET DEFAULT now();
ALTER TABLE workpictureinstance ALTER workpictureinstancemodifieddate SET DEFAULT now();
ALTER TABLE workpictureinstance ALTER workpictureinstanceuuid SET DEFAULT concat('work-picture-instance_', gen_random_uuid());

ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_pkey PRIMARY KEY (workpictureinstanceid);
ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstancecustomerid_fkey FOREIGN KEY (workpictureinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstancemimetypeid_fkey FOREIGN KEY (workpictureinstancemimetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstancemodifiedby_fkey FOREIGN KEY (workpictureinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstanceworkinstanceid_fkey FOREIGN KEY (workpictureinstanceworkinstanceid) REFERENCES workinstance(workinstanceid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstanceworkresultinstancei_fkey FOREIGN KEY (workpictureinstanceworkresultinstanceid) REFERENCES workresultinstance(workresultinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

CREATE UNIQUE INDEX workpictureinstance_workpictureinstanceuuid_key ON public.workpictureinstance USING btree (workpictureinstanceuuid);
CREATE INDEX workpictureinstance_workpictureinstanceworkinstanceid_idx ON public.workpictureinstance USING btree (workpictureinstanceworkinstanceid);

GRANT INSERT ON workpictureinstance TO authenticated;
GRANT SELECT ON workpictureinstance TO authenticated;
GRANT UPDATE ON workpictureinstance TO authenticated;
GRANT DELETE ON workpictureinstance TO graphql;
GRANT INSERT ON workpictureinstance TO graphql;
GRANT REFERENCES ON workpictureinstance TO graphql;
GRANT SELECT ON workpictureinstance TO graphql;
GRANT TRIGGER ON workpictureinstance TO graphql;
GRANT TRUNCATE ON workpictureinstance TO graphql;
GRANT UPDATE ON workpictureinstance TO graphql;

-- Type: SEQUENCE ; Name: workpictureinstance_workpictureinstanceid_seq; Owner: tendreladmin

ALTER TABLE workpictureinstance ALTER workpictureinstanceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: workresource_workresourceid_seq; Owner: tendreladmin

ALTER TABLE workresource ALTER workresourceid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: workresult_workresultid_seq; Owner: tendreladmin

ALTER TABLE workresult ALTER workresultid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: workresultcalculated_workresultcalculatedid_seq; Owner: tendreladmin

ALTER TABLE workresultcalculated ALTER workresultcalculatedid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: worktemplate_worktemplateid_seq; Owner: tendreladmin

ALTER TABLE worktemplate ALTER worktemplateid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: worktemplatedurationcalculation; Owner: tendreladmin

CREATE TABLE worktemplatedurationcalculation (
    worktemplatedurationcalculationid bigint GENERATED ALWAYS AS IDENTITY,
    worktemplatedurationcalculationcustomerid bigint NOT NULL,
    worktemplatedurationcalculationsiteid bigint NOT NULL,
    worktemplatedurationcalculationworktemplateid bigint NOT NULL,
    worktemplatedurationcalculationworktypeid bigint NOT NULL,
    worktemplatedurationcalculationcalculationtypeid bigint NOT NULL,
    worktemplatedurationcalculationworkcount bigint,
    worktemplatedurationcalculationp99 numeric,
    worktemplatedurationcalculationp90 numeric,
    worktemplatedurationcalculationp75 numeric,
    worktemplatedurationcalculationp66 numeric,
    worktemplatedurationcalculationp50 numeric,
    worktemplatedurationcalculationp25 numeric,
    worktemplatedurationcalculationp10 numeric,
    worktemplatedurationcalculationp1 numeric,
    worktemplatedurationcalculationmode numeric,
    worktemplatedurationcalculationavg numeric,
    worktemplatedurationcalculationstddevsample numeric,
    worktemplatedurationcalculationstddevpop numeric,
    worktemplatedurationcalculationvarsample numeric,
    worktemplatedurationcalculationvarpop numeric,
    worktemplatedurationcalculationenddate timestamp(3) with time zone NOT NULL,
    worktemplatedurationcalculationcreateddate timestamp(3) with time zone,
    worktemplatedurationcalculationmodifieddate timestamp(3) with time zone,
    worktemplatedurationcalculationexternalid text,
    worktemplatedurationcalculationexternalsystemid bigint,
    worktemplatedurationcalculationmodifiedby bigint,
    worktemplatedurationcalculationrefid bigint
);


ALTER TABLE worktemplatedurationcalculation ALTER worktemplatedurationcalculationcreateddate SET DEFAULT now();
ALTER TABLE worktemplatedurationcalculation ALTER worktemplatedurationcalculationmodifieddate SET DEFAULT now();

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT worktemplatedurationcalculation_pkey PRIMARY KEY (worktemplatedurationcalculationid);
ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT calculationtype_fkey FOREIGN KEY (worktemplatedurationcalculationcalculationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT customerid_fkey FOREIGN KEY (worktemplatedurationcalculationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT siteid_fkey FOREIGN KEY (worktemplatedurationcalculationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT templateid_fkey FOREIGN KEY (worktemplatedurationcalculationworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT worktemplatedurationcalculation_worktemplatedurationcalcul_fkey FOREIGN KEY (worktemplatedurationcalculationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT worktype_fkey FOREIGN KEY (worktemplatedurationcalculationworktypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

GRANT INSERT ON worktemplatedurationcalculation TO authenticated;
GRANT SELECT ON worktemplatedurationcalculation TO authenticated;
GRANT UPDATE ON worktemplatedurationcalculation TO authenticated;
GRANT DELETE ON worktemplatedurationcalculation TO graphql;
GRANT INSERT ON worktemplatedurationcalculation TO graphql;
GRANT REFERENCES ON worktemplatedurationcalculation TO graphql;
GRANT SELECT ON worktemplatedurationcalculation TO graphql;
GRANT TRIGGER ON worktemplatedurationcalculation TO graphql;
GRANT TRUNCATE ON worktemplatedurationcalculation TO graphql;
GRANT UPDATE ON worktemplatedurationcalculation TO graphql;

-- Type: SEQUENCE ; Name: worktemplatedurationcalculati_worktemplatedurationcalculati_seq; Owner: tendreladmin

ALTER TABLE worktemplatedurationcalculation ALTER worktemplatedurationcalculationid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: SEQUENCE ; Name: worktemplatenexttemplate_worktemplatenexttemplateid_seq; Owner: tendreladmin

ALTER TABLE worktemplatenexttemplate ALTER worktemplatenexttemplateid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workweek; Owner: tendreladmin

CREATE TABLE workweek (
    workweekid bigint GENERATED ALWAYS AS IDENTITY,
    workweekcustomerid bigint,
    workweeklocationid bigint,
    workweektimezoneid bigint,
    workweekname text,
    workweekstartdate timestamp(3) with time zone,
    workweekenddate timestamp(3) with time zone,
    workweekmonday boolean,
    workweektuesday boolean,
    workweekwednesday boolean,
    workweekthursday boolean,
    workweekfriday boolean,
    workweeksaturday boolean,
    workweeksunday boolean,
    workweekcreateddate timestamp(3) with time zone,
    workweekexternalsystemid bigint,
    workweekexternalid bigint,
    workweekmodifieddate timestamp(3) with time zone,
    workweekmondaystarttime timestamp(3) with time zone,
    workweekmondayendtime timestamp(3) with time zone,
    workweektuesdaystarttime timestamp(3) with time zone,
    workweektuesdayendtime timestamp(3) with time zone,
    workweekwednesdaystarttime timestamp(3) with time zone,
    workweekwednesdayendtime timestamp(3) with time zone,
    workweekthursdaystarttime timestamp(3) with time zone,
    workweekthursdayendtime timestamp(3) with time zone,
    workweekfridaystarttime timestamp(3) with time zone,
    workweekfridayendtime timestamp(3) with time zone,
    workweeksaturdaystarttime timestamp(3) with time zone,
    workweeksaturdayendtime timestamp(3) with time zone,
    workweeksundaystarttime timestamp(3) with time zone,
    workweeksundayendtime timestamp(3) with time zone
);


ALTER TABLE workweek ALTER workweekcreateddate SET DEFAULT now();
ALTER TABLE workweek ALTER workweekmodifieddate SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE workweek ADD CONSTRAINT workweek_pkey PRIMARY KEY (workweekid);
ALTER TABLE workweek ADD CONSTRAINT customerid_fkey FOREIGN KEY (workweekcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workweek ADD CONSTRAINT locationid_fkey FOREIGN KEY (workweeklocationid) REFERENCES location(locationid) NOT VALID;
ALTER TABLE workweek ADD CONSTRAINT timezoneid_fkey FOREIGN KEY (workweektimezoneid) REFERENCES systag(systagid) NOT VALID;

GRANT INSERT ON workweek TO authenticated;
GRANT SELECT ON workweek TO authenticated;
GRANT UPDATE ON workweek TO authenticated;
GRANT DELETE ON workweek TO graphql;
GRANT INSERT ON workweek TO graphql;
GRANT REFERENCES ON workweek TO graphql;
GRANT SELECT ON workweek TO graphql;
GRANT TRIGGER ON workweek TO graphql;
GRANT TRUNCATE ON workweek TO graphql;
GRANT UPDATE ON workweek TO graphql;

-- Type: SEQUENCE ; Name: workweek_workweekid_seq; Owner: tendreladmin

ALTER TABLE workweek ALTER workweekid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: workweekexception; Owner: tendreladmin

CREATE TABLE workweekexception (
    workweekexceptionid bigint GENERATED ALWAYS AS IDENTITY,
    workweekexceptioncustomerid bigint,
    workweekexceptionlocationid bigint,
    workweekexceptionname text,
    workweekexceptiondate timestamp(3) with time zone,
    workweekexceptiontimezoneid bigint,
    workweekexceptionworkday boolean,
    workweekexceptioncreateddate timestamp(3) with time zone NOT NULL,
    workweekexceptionexternalsystemid bigint,
    workweekexceptionexternalid bigint,
    workweekexceptionmodifieddate timestamp(3) with time zone NOT NULL,
    workweekexceptionstarttime timestamp(3) with time zone,
    workweekexceptionendtime timestamp(3) with time zone
);


ALTER TABLE workweekexception ALTER workweekexceptioncreateddate SET DEFAULT now();
ALTER TABLE workweekexception ALTER workweekexceptionmodifieddate SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE workweekexception ADD CONSTRAINT workweekexception_pkey PRIMARY KEY (workweekexceptionid);
ALTER TABLE workweekexception ADD CONSTRAINT customerid_fkey FOREIGN KEY (workweekexceptioncustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE workweekexception ADD CONSTRAINT locationid_fkey FOREIGN KEY (workweekexceptionlocationid) REFERENCES location(locationid);
ALTER TABLE workweekexception ADD CONSTRAINT timezoneid_fkey FOREIGN KEY (workweekexceptiontimezoneid) REFERENCES systag(systagid);

GRANT INSERT ON workweekexception TO authenticated;
GRANT SELECT ON workweekexception TO authenticated;
GRANT UPDATE ON workweekexception TO authenticated;
GRANT DELETE ON workweekexception TO graphql;
GRANT INSERT ON workweekexception TO graphql;
GRANT REFERENCES ON workweekexception TO graphql;
GRANT SELECT ON workweekexception TO graphql;
GRANT TRIGGER ON workweekexception TO graphql;
GRANT TRUNCATE ON workweekexception TO graphql;
GRANT UPDATE ON workweekexception TO graphql;

-- Type: SEQUENCE ; Name: workweekexception_workweekexceptionid_seq; Owner: tendreladmin

ALTER TABLE workweekexception ALTER workweekexceptionid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: xlabel; Owner: tendreladmin

CREATE TABLE xlabel (
    xlabelid bigint GENERATED ALWAYS AS IDENTITY,
    xlabelcustomerid bigint,
    xlabeltableid bigint,
    xlabeltypeid bigint,
    xlabeltypename text,
    xlabelnameid bigint,
    xlabelname text,
    xlabelcreateddate timestamp(3) with time zone NOT NULL,
    xlabelmodifieddate timestamp(3) with time zone NOT NULL,
    xlabelstartdate timestamp(3) with time zone,
    xlabelenddate timestamp(3) with time zone
);


ALTER TABLE xlabel ALTER xlabelcreateddate SET DEFAULT now();
ALTER TABLE xlabel ALTER xlabelmodifieddate SET DEFAULT now();
ALTER TABLE xlabel ALTER xlabelstartdate SET DEFAULT now();

ALTER TABLE xlabel ADD CONSTRAINT xlabel_pkey PRIMARY KEY (xlabelid);
ALTER TABLE xlabel ADD CONSTRAINT customerid_fkey FOREIGN KEY (xlabelcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE xlabel ADD CONSTRAINT labelnameid_fkey FOREIGN KEY (xlabelnameid) REFERENCES custag(custagid) NOT VALID;
ALTER TABLE xlabel ADD CONSTRAINT labletypeid_fkey FOREIGN KEY (xlabeltypeid) REFERENCES systag(systagid) NOT VALID;

GRANT INSERT ON xlabel TO authenticated;
GRANT SELECT ON xlabel TO authenticated;
GRANT UPDATE ON xlabel TO authenticated;
GRANT DELETE ON xlabel TO graphql;
GRANT INSERT ON xlabel TO graphql;
GRANT REFERENCES ON xlabel TO graphql;
GRANT SELECT ON xlabel TO graphql;
GRANT TRIGGER ON xlabel TO graphql;
GRANT TRUNCATE ON xlabel TO graphql;
GRANT UPDATE ON xlabel TO graphql;

-- Type: SEQUENCE ; Name: xlabel_xlabelid_seq; Owner: tendreladmin

ALTER TABLE xlabel ALTER xlabelid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: TABLE ; Name: xtag; Owner: tendreladmin

CREATE TABLE xtag (
    xtagid bigint GENERATED ALWAYS AS IDENTITY,
    xtagcustomerid bigint,
    xsysparenttagid bigint,
    xsystagid bigint,
    xtagname character varying,
    xtagcreateddate timestamp(3) with time zone NOT NULL,
    xtagmodifieddate timestamp(3) with time zone NOT NULL,
    xtagstartdate timestamp(3) with time zone,
    xtagenddate timestamp(3) with time zone
);


ALTER TABLE xtag ALTER xtagcreateddate SET DEFAULT now();
ALTER TABLE xtag ALTER xtagmodifieddate SET DEFAULT now();
ALTER TABLE xtag ALTER xtagstartdate SET DEFAULT now();

ALTER TABLE xtag ADD CONSTRAINT xtag_pkey PRIMARY KEY (xtagid);
ALTER TABLE xtag ADD CONSTRAINT xtag_xsysparenttagid_fkey FOREIGN KEY (xsysparenttagid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE xtag ADD CONSTRAINT xtag_xsystagid_fkey FOREIGN KEY (xsystagid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE xtag ADD CONSTRAINT xtag_xtagcustomerid_fkey FOREIGN KEY (xtagcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

GRANT INSERT ON xtag TO authenticated;
GRANT SELECT ON xtag TO authenticated;
GRANT UPDATE ON xtag TO authenticated;
GRANT DELETE ON xtag TO graphql;
GRANT INSERT ON xtag TO graphql;
GRANT REFERENCES ON xtag TO graphql;
GRANT SELECT ON xtag TO graphql;
GRANT TRIGGER ON xtag TO graphql;
GRANT TRUNCATE ON xtag TO graphql;
GRANT UPDATE ON xtag TO graphql;

-- Type: SEQUENCE ; Name: xtag_xtagid_seq; Owner: tendreladmin

ALTER TABLE xtag ALTER xtagid ADD GENERATED ALWAYS AS IDENTITY;



-- Type: VIEW ; Name: customer_requested_language; Owner: tendreladmin

CREATE OR REPLACE VIEW api.customer_requested_language AS
 SELECT crl.customerrequestedlanguageid AS legacy_id,
    crl.customerrequestedlanguagecustomerid AS legacy_customer_id,
    customer.customerentityuuid AS owner,
    customer.customerdisplayname AS owner_name,
    lang.systagentityuuid AS languagetype_id,
    lang.systagname AS name,
    lang.systagdisplayname AS displayname,
    crl.customerrequestedlanguagestartdate AS activated_at,
    crl.customerrequestedlanguageenddate AS deactivated_at,
    crl.customerrequestedlanguagecreateddate AS created_at,
    crl.customerrequestedlanguagemodifieddate AS updated_at,
    crl.customerrequestedlanguageexternalid AS external_id,
    crl.customerrequestedlanguageexternalsystemid AS external_system,
        CASE
            WHEN crl.customerrequestedlanguagestartdate IS NULL THEN true
            ELSE false
        END AS customerrequestedlanguagedraft,
        CASE
            WHEN crl.customerrequestedlanguageenddate::date < now()::date THEN true
            ELSE false
        END AS customerrequestedlanguagedeleted,
        CASE
            WHEN (crl.customerrequestedlanguageenddate::date > now()::date OR crl.customerrequestedlanguageenddate::date IS NULL) AND crl.customerrequestedlanguagestartdate < now() THEN true
            ELSE false
        END AS customerrequestedlanguageactive,
    crl.customerrequestedlanguagemodifiedby AS modified_by,
    crl.customerrequestedlanguageuuid AS id
   FROM customerrequestedlanguage crl
     JOIN ( SELECT crud_customer_read_full.customerid,
            crud_customer_read_full.customeruuid,
            crud_customer_read_full.customerentityuuid,
            crud_customer_read_full.customerownerentityuuid,
            crud_customer_read_full.customerparententityuuid,
            crud_customer_read_full.customercornerstoneentityuuid,
            crud_customer_read_full.customercornerstoneorder,
            crud_customer_read_full.customernameuuid,
            crud_customer_read_full.customername,
            crud_customer_read_full.customerdisplaynameuuid,
            crud_customer_read_full.customerdisplayname,
            crud_customer_read_full.customertypeentityuuid,
            crud_customer_read_full.customertype,
            crud_customer_read_full.customercreateddate,
            crud_customer_read_full.customermodifieddate,
            crud_customer_read_full.customerstartdate,
            crud_customer_read_full.customerenddate,
            crud_customer_read_full.customermodifiedbyuuid,
            crud_customer_read_full.customerexternalid,
            crud_customer_read_full.customerexternalsystementityuuid,
            crud_customer_read_full.customerexternalsystemname,
            crud_customer_read_full.customerrefid,
            crud_customer_read_full.customerrefuuid,
            crud_customer_read_full.customerlanguagetypeentityuuid,
            crud_customer_read_full.customersenddeleted,
            crud_customer_read_full.customersenddrafts,
            crud_customer_read_full.customersendinactive
           FROM entity.crud_customer_read_full(NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_customer_read_full(customerid, customeruuid, customerentityuuid, customerownerentityuuid, customerparententityuuid, customercornerstoneentityuuid, customercornerstoneorder, customernameuuid, customername, customerdisplaynameuuid, customerdisplayname, customertypeentityuuid, customertype, customercreateddate, customermodifieddate, customerstartdate, customerenddate, customermodifiedbyuuid, customerexternalid, customerexternalsystementityuuid, customerexternalsystemname, customerrefid, customerrefuuid, customerlanguagetypeentityuuid, customersenddeleted, customersenddrafts, customersendinactive)) customer ON customer.customerid = crl.customerrequestedlanguagecustomerid
     JOIN ( SELECT crud_systag_read_full.languagetranslationtypeentityuuid,
            crud_systag_read_full.systagid,
            crud_systag_read_full.systaguuid,
            crud_systag_read_full.systagentityuuid,
            crud_systag_read_full.systagcustomerid,
            crud_systag_read_full.systagcustomeruuid,
            crud_systag_read_full.systagcustomerentityuuid,
            crud_systag_read_full.systagcustomername,
            crud_systag_read_full.systagnameuuid,
            crud_systag_read_full.systagname,
            crud_systag_read_full.systagdisplaynameuuid,
            crud_systag_read_full.systagdisplayname,
            crud_systag_read_full.systagtype,
            crud_systag_read_full.systagcreateddate,
            crud_systag_read_full.systagmodifieddate,
            crud_systag_read_full.systagstartdate,
            crud_systag_read_full.systagenddate,
            crud_systag_read_full.systagexternalid,
            crud_systag_read_full.systagexternalsystementityuuid,
            crud_systag_read_full.systagexternalsystementname,
            crud_systag_read_full.systagmodifiedbyuuid,
            crud_systag_read_full.systagabbreviationentityuuid,
            crud_systag_read_full.systagabbreviationname,
            crud_systag_read_full.systagparententityuuid,
            crud_systag_read_full.systagparentname,
            crud_systag_read_full.systagorder,
            crud_systag_read_full.systagsenddeleted,
            crud_systag_read_full.systagsenddrafts,
            crud_systag_read_full.systagsendinactive
           FROM entity.crud_systag_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_systag_read_full(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagcustomername, systagnameuuid, systagname, systagdisplaynameuuid, systagdisplayname, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagexternalsystementname, systagmodifiedbyuuid, systagabbreviationentityuuid, systagabbreviationname, systagparententityuuid, systagparentname, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) lang ON lang.systagid = crl.customerrequestedlanguagelanguageid
  WHERE (customer.customerownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.customer_requested_language IS '
## customer_requested_language

A description of what an customer is and why it is used

### get {baseUrl}/customer_requested_language

A bunch of comments explaining get

### del {baseUrl}/customer_requested_language

A bunch of comments explaining del

### patch {baseUrl}/customer_requested_language

A bunch of comments explaining patch
';

CREATE TRIGGER create_customer_requested_language_tg INSTEAD OF INSERT ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.create_customer_requested_language();
CREATE TRIGGER update_customer_requested_language_tg INSTEAD OF UPDATE ON api.customer_requested_language FOR EACH ROW EXECUTE FUNCTION api.update_customer_requested_language();

GRANT INSERT ON api.customer_requested_language TO authenticated;
GRANT SELECT ON api.customer_requested_language TO authenticated;
GRANT UPDATE ON api.customer_requested_language TO authenticated;

-- Type: TABLE ; Name: languagemaster; Owner: tendreladmin

CREATE TABLE languagemaster (
    languagemasterid bigint GENERATED ALWAYS AS IDENTITY,
    languagemastercustomerid bigint NOT NULL,
    languagemastercustomersiteid bigint,
    languagemastersourcelanguagetypeid bigint NOT NULL,
    languagemastersource text NOT NULL,
    languagemastercreateddate timestamp(3) with time zone NOT NULL,
    languagemastermodifieddate timestamp(3) with time zone NOT NULL,
    languagemasterstatus "TranslationStatus" NOT NULL,
    languagemastertranslationtime timestamp(3) with time zone,
    languagemasterexternalid text,
    languagemasterexternalsystemid bigint,
    languagemastermodifiedby bigint,
    languagemasterrefid bigint,
    languagemasterrefuuid text,
    languagemasteruuid text NOT NULL
);


ALTER TABLE languagemaster ALTER languagemastercreateddate SET DEFAULT now();
ALTER TABLE languagemaster ALTER languagemastermodifieddate SET DEFAULT now();
ALTER TABLE languagemaster ALTER languagemasterstatus SET DEFAULT 'NEEDS_TRANSLATION'::"TranslationStatus";
ALTER TABLE languagemaster ALTER languagemastertranslationtime SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE languagemaster ALTER languagemasteruuid SET DEFAULT concat('lm_', gen_random_uuid());

ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_pkey PRIMARY KEY (languagemasterid);
ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastercustomerid_fkey FOREIGN KEY (languagemastercustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastercustomersiteid_fkey FOREIGN KEY (languagemastercustomersiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastermodifiedby_fkey FOREIGN KEY (languagemastermodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastersourcelanguagetypeid_fkey FOREIGN KEY (languagemastersourcelanguagetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE INDEX languagemaster_languagemastercustomersiteid_idx ON public.languagemaster USING btree (languagemastercustomersiteid);
CREATE INDEX languagemaster_languagemasterrefid_idx ON public.languagemaster USING btree (languagemasterrefid);
CREATE INDEX languagemaster_languagemasterrefuuid_idx ON public.languagemaster USING btree (languagemasterrefuuid);
CREATE INDEX languagemaster_languagemasterstatus_idx ON public.languagemaster USING btree (languagemasterstatus);
CREATE INDEX languagemaster_languagemastertranslationtime_idx ON public.languagemaster USING btree (languagemastertranslationtime);
CREATE UNIQUE INDEX languagemaster_languagemasteruuid_key ON public.languagemaster USING btree (languagemasteruuid);

GRANT INSERT ON languagemaster TO authenticated;
GRANT SELECT ON languagemaster TO authenticated;
GRANT UPDATE ON languagemaster TO authenticated;
GRANT DELETE ON languagemaster TO graphql;
GRANT INSERT ON languagemaster TO graphql;
GRANT REFERENCES ON languagemaster TO graphql;
GRANT SELECT ON languagemaster TO graphql;
GRANT TRIGGER ON languagemaster TO graphql;
GRANT TRUNCATE ON languagemaster TO graphql;
GRANT UPDATE ON languagemaster TO graphql;
ALTER TABLE languagemaster ALTER languagemasterstatus SET DEFAULT 'NEEDS_TRANSLATION'::"TranslationStatus";

-- Type: TABLE ; Name: registereddevice; Owner: tendreladmin

CREATE TABLE registereddevice (
    registereddeviceid bigint NOT NULL,
    registereddevicecreateddate timestamp(3) with time zone NOT NULL,
    registereddevicemodifieddate timestamp(3) with time zone NOT NULL,
    registereddeviceenddate timestamp(3) with time zone,
    registereddevicefriendlyname text,
    registereddevicedevicetype "DeviceType" NOT NULL,
    registereddeviceplatform "Platform",
    registereddeviceexternalid text,
    registereddeviceexternalsystemid bigint,
    registereddevicemodifiedby bigint,
    registereddevicerefid bigint,
    registereddeviceudid text NOT NULL,
    registereddeviceuserroleid bigint NOT NULL,
    registereddevicecustomerbackfilled boolean NOT NULL,
    registereddeviceapikeybackfilled boolean NOT NULL
);


ALTER TABLE registereddevice ALTER registereddevicecreateddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE registereddevice ALTER registereddevicemodifieddate SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE registereddevice ALTER registereddevicecustomerbackfilled SET DEFAULT false;
ALTER TABLE registereddevice ALTER registereddeviceapikeybackfilled SET DEFAULT false;

CREATE SEQUENCE IF NOT EXISTS registereddevice_registereddeviceid_seq;
ALTER SEQUENCE registereddevice_registereddeviceid_seq OWNED BY registereddevice.registereddeviceid;

ALTER TABLE registereddevice ADD CONSTRAINT registereddevice_pkey PRIMARY KEY (registereddeviceid);
ALTER TABLE registereddevice ADD CONSTRAINT registereddevice_registereddevicemodifiedby_fkey FOREIGN KEY (registereddevicemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE registereddevice ADD CONSTRAINT registereddevice_registereddeviceuserroleid_fkey FOREIGN KEY (registereddeviceuserroleid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE UNIQUE INDEX registereddevice_registereddeviceudid_key ON public.registereddevice USING btree (registereddeviceudid);

GRANT INSERT ON registereddevice TO authenticated;
GRANT SELECT ON registereddevice TO authenticated;
GRANT UPDATE ON registereddevice TO authenticated;
GRANT DELETE ON registereddevice TO graphql;
GRANT INSERT ON registereddevice TO graphql;
GRANT REFERENCES ON registereddevice TO graphql;
GRANT SELECT ON registereddevice TO graphql;
GRANT TRIGGER ON registereddevice TO graphql;
GRANT TRUNCATE ON registereddevice TO graphql;
GRANT UPDATE ON registereddevice TO graphql;

-- Type: VIEW ; Name: view_customer; Owner: tendreladmin

CREATE OR REPLACE VIEW view_customer AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    customer.customercreateddate,
    customer.customerenddate,
    customer.customerexternalid,
    customer.customerexternalsystemid,
    customer.customerexternalsystemuuid,
    customer.customerid,
    customer.customeruuid,
    customer.customermodifiedby,
    customer.customermodifieddate,
    customer.customername,
    customer.customerstartdate,
    customer.customertypeuuid
   FROM customer
     JOIN customerrequestedlanguage crl ON customer.customerid = crl.customerrequestedlanguagecustomerid;


GRANT INSERT ON view_customer TO authenticated;
GRANT SELECT ON view_customer TO authenticated;
GRANT UPDATE ON view_customer TO authenticated;
GRANT DELETE ON view_customer TO graphql;
GRANT INSERT ON view_customer TO graphql;
GRANT REFERENCES ON view_customer TO graphql;
GRANT SELECT ON view_customer TO graphql;
GRANT TRIGGER ON view_customer TO graphql;
GRANT TRUNCATE ON view_customer TO graphql;
GRANT UPDATE ON view_customer TO graphql;

-- Type: VIEW ; Name: view_customerrequestedlanguage; Owner: tendreladmin

CREATE OR REPLACE VIEW view_customerrequestedlanguage AS
 SELECT customerrequestedlanguagelanguageid,
    customerrequestedlanguagecreateddate,
    customerrequestedlanguagecustomerid,
    customerrequestedlanguageenddate,
    customerrequestedlanguageexternalid,
    customerrequestedlanguageexternalsystemid,
    customerrequestedlanguageid,
    customerrequestedlanguagemodifiedby,
    customerrequestedlanguagemodifieddate,
    customerrequestedlanguagestartdate
   FROM customerrequestedlanguage;


GRANT INSERT ON view_customerrequestedlanguage TO authenticated;
GRANT SELECT ON view_customerrequestedlanguage TO authenticated;
GRANT UPDATE ON view_customerrequestedlanguage TO authenticated;
GRANT DELETE ON view_customerrequestedlanguage TO graphql;
GRANT INSERT ON view_customerrequestedlanguage TO graphql;
GRANT REFERENCES ON view_customerrequestedlanguage TO graphql;
GRANT SELECT ON view_customerrequestedlanguage TO graphql;
GRANT TRIGGER ON view_customerrequestedlanguage TO graphql;
GRANT TRUNCATE ON view_customerrequestedlanguage TO graphql;
GRANT UPDATE ON view_customerrequestedlanguage TO graphql;

-- Type: VIEW ; Name: view_workdescription; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workdescription AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    wd.workdescriptioncreateddate,
    wd.workdescriptioncustomerid,
    wd.workdescriptionenddate,
    wd.workdescriptionexternalid,
    wd.workdescriptionexternalsystemid,
    wd.workdescriptionid,
    wd.workdescriptionlanguagemasterid,
    wd.workdescriptionlanguagetypeid,
    wd.workdescriptionmodifiedby,
    wd.workdescriptionmodifieddate,
    wd.workdescriptionstartdate,
    wd.workdescriptionworktemplateid,
    lt.languagetranslationvalue AS worktemplatedescription,
    wd.workdescriptionsoplink AS worktemplatesoplink
   FROM workdescription wd
     JOIN customerrequestedlanguage crl ON wd.workdescriptioncustomerid = crl.customerrequestedlanguagecustomerid
     LEFT JOIN languagetranslations lt ON crl.customerrequestedlanguagelanguageid = lt.languagetranslationtypeid AND wd.workdescriptionlanguagemasterid = lt.languagetranslationmasterid AND wd.workdescriptioncustomerid = lt.languagetranslationcustomerid;


GRANT INSERT ON view_workdescription TO authenticated;
GRANT SELECT ON view_workdescription TO authenticated;
GRANT UPDATE ON view_workdescription TO authenticated;
GRANT DELETE ON view_workdescription TO graphql;
GRANT INSERT ON view_workdescription TO graphql;
GRANT REFERENCES ON view_workdescription TO graphql;
GRANT SELECT ON view_workdescription TO graphql;
GRANT TRIGGER ON view_workdescription TO graphql;
GRANT TRUNCATE ON view_workdescription TO graphql;
GRANT UPDATE ON view_workdescription TO graphql;

-- Type: VIEW ; Name: view_worker; Owner: tendreladmin

CREATE OR REPLACE VIEW view_worker AS
 SELECT workeraddressid,
    workercreateddate,
    workeremail,
    workerenddate,
    workerexternalid,
    workerexternalsystemid,
    workerexternalsystemuuid,
    workerfirstname,
    workerfullname,
    workerid,
    workeruuid,
    workeridentitysystemuuid,
    workerlanguageid,
    workerlastname,
    workermodifiedby,
    workermodifieddate,
    workerpassword,
    workerphonenumber,
    workerstartdate,
    workerusername,
    workerdatacomplete,
    workeridentityid,
    workeridentitysystemid,
    workergeneratedname
   FROM worker;


GRANT INSERT ON view_worker TO authenticated;
GRANT SELECT ON view_worker TO authenticated;
GRANT UPDATE ON view_worker TO authenticated;
GRANT DELETE ON view_worker TO graphql;
GRANT INSERT ON view_worker TO graphql;
GRANT REFERENCES ON view_worker TO graphql;
GRANT SELECT ON view_worker TO graphql;
GRANT TRIGGER ON view_worker TO graphql;
GRANT TRUNCATE ON view_worker TO graphql;
GRANT UPDATE ON view_worker TO graphql;

-- Type: VIEW ; Name: view_worktemplatenexttemplate; Owner: tendreladmin

CREATE OR REPLACE VIEW view_worktemplatenexttemplate AS
 SELECT worktemplatenexttemplatecreateddate,
    worktemplatenexttemplatecustomerid,
    worktemplatenexttemplateenddate,
    worktemplatenexttemplateexternalid,
    worktemplatenexttemplateexternalsystemid,
    worktemplatenexttemplateid,
    worktemplatenexttemplatemodifiedby,
    worktemplatenexttemplatemodifieddate,
    worktemplatenexttemplatenexttemplateid,
    worktemplatenexttemplateprevioustemplateid,
    worktemplatenexttemplatesiteid,
    worktemplatenexttemplatestartdate,
    worktemplatenexttemplatetypeid,
    worktemplatenexttemplateviastatuschange,
    worktemplatenexttemplateviastatuschangeid,
    worktemplatenexttemplateviaworkresultcontstraintid,
    worktemplatenexttemplateviaworkresultid,
    worktemplatenexttemplateviaworkresultvalue
   FROM worktemplatenexttemplate;


GRANT INSERT ON view_worktemplatenexttemplate TO authenticated;
GRANT SELECT ON view_worktemplatenexttemplate TO authenticated;
GRANT UPDATE ON view_worktemplatenexttemplate TO authenticated;
GRANT DELETE ON view_worktemplatenexttemplate TO graphql;
GRANT INSERT ON view_worktemplatenexttemplate TO graphql;
GRANT REFERENCES ON view_worktemplatenexttemplate TO graphql;
GRANT SELECT ON view_worktemplatenexttemplate TO graphql;
GRANT TRIGGER ON view_worktemplatenexttemplate TO graphql;
GRANT TRUNCATE ON view_worktemplatenexttemplate TO graphql;
GRANT UPDATE ON view_worktemplatenexttemplate TO graphql;

-- Type: VIEW ; Name: view_workinstances_with_invalid_location; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workinstances_with_invalid_location AS
 SELECT wi.workinstanceid,
    wi.workinstancecustomerid,
    wi.workinstanceworktemplateid,
    wi.workinstancesiteid,
    wi.workinstancetypeid,
    wi.workinstancestatusid,
    wi.workinstancepreviousid,
    wi.workinstancecreateddate,
    wi.workinstancemodifieddate,
    wi.workinstancetargetstartdate,
    wi.workinstancestartdate,
    wi.workinstancecompleteddate,
    wi.workinstanceexpecteddurationinseconds,
    wi.workinstanceexternalsystemid,
    wi.workinstanceexternalid,
    wi.workinstancesoplink,
    wi.workinstancetrustreasoncodeid,
    wi.workinstanceoriginatorworkinstanceid,
    wi.id,
    wi.version,
    wi.workinstancetimezone,
    wi.workinstancecompleteddatetz,
    wi.workinstancestartdatetz,
    wi.workinstancetargetstartdatetz,
    wi.workinstancemodifiedby,
    wi.workinstancerefid,
    wi.workinstancerefuuid,
    location.locationid AS workinstancelocationid
   FROM workinstance wi
     JOIN workresult wrl ON wi.workinstanceworktemplateid = wrl.workresultworktemplateid AND wrl.workresulttypeid = 848 AND wrl.workresultentitytypeid = 852 AND wrl.workresultisprimary = true
     LEFT JOIN workresultinstance wril ON wi.workinstanceid = wril.workresultinstanceworkinstanceid AND wrl.workresultid = wril.workresultinstanceworkresultid AND wril.workresultinstancevalue IS NOT NULL AND wril.workresultinstancevalue <> ''::text
     LEFT JOIN location ON wril.workresultinstancevalue::bigint = location.locationid;


GRANT INSERT ON view_workinstances_with_invalid_location TO authenticated;
GRANT SELECT ON view_workinstances_with_invalid_location TO authenticated;
GRANT UPDATE ON view_workinstances_with_invalid_location TO authenticated;
GRANT DELETE ON view_workinstances_with_invalid_location TO graphql;
GRANT INSERT ON view_workinstances_with_invalid_location TO graphql;
GRANT REFERENCES ON view_workinstances_with_invalid_location TO graphql;
GRANT SELECT ON view_workinstances_with_invalid_location TO graphql;
GRANT TRIGGER ON view_workinstances_with_invalid_location TO graphql;
GRANT TRUNCATE ON view_workinstances_with_invalid_location TO graphql;
GRANT UPDATE ON view_workinstances_with_invalid_location TO graphql;

-- Type: VIEW ; Name: location; Owner: tendreladmin

CREATE OR REPLACE VIEW api.location AS
 SELECT location.locationid AS legacy_id,
    location.locationuuid AS legacy_uuid,
    location.locationentityuuid AS id,
    location.locationownerentityuuid AS owner,
    location.locationcustomername AS owner_name,
    location.locationparententityuuid AS parent,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS parent_name,
    location.locationcornerstoneentityuuid AS cornerstone,
    location.locationnameuuid AS name_id,
    location.locationname AS name,
    location.locationdisplaynameuuid AS displayname_id,
    location.locationdisplayname AS displayname,
    location.locationscanid AS scan_code,
    location.locationcreateddate AS created_at,
    location.locationmodifieddate AS updated_at,
    location.locationmodifiedbyuuid AS modified_by,
    location.locationstartdate AS activated_at,
    location.locationenddate AS deactivated_at,
    location.locationexternalid AS external_id,
    location.locationexternalsystementityuuid AS external_system,
    location.locationcornerstoneorder AS _order,
    location.locationlatitude AS latitude,
    location.locationlongitude AS longitude,
    location.locationradius AS radius,
    location.locationtimezone AS timezone,
    location.locationtagentityuuid AS tag_id,
    location.locationsenddeleted AS _deleted,
    location.locationsenddrafts AS _draft,
    location.locationsendinactive AS _active,
        CASE
            WHEN location.locationparententityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_site,
        CASE
            WHEN location.locationcornerstoneentityuuid = location.locationentityuuid THEN true
            ELSE false
        END AS _is_cornerstone
   FROM entity.crud_location_read_full(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
           FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) location(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationcustomername, locationnameuuid, locationname, locationdisplaynameuuid, locationdisplayname, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationexternalsystementname, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationtagname, locationsenddeleted, locationsenddrafts, locationsendinactive)
     LEFT JOIN ( SELECT crud_location_read_min.languagetranslationtypeentityuuid,
            crud_location_read_min.locationid,
            crud_location_read_min.locationuuid,
            crud_location_read_min.locationentityuuid,
            crud_location_read_min.locationownerentityuuid,
            crud_location_read_min.locationparententityuuid,
            crud_location_read_min.locationcornerstoneentityuuid,
            crud_location_read_min.locationcustomerid,
            crud_location_read_min.locationcustomeruuid,
            crud_location_read_min.locationcustomerentityuuid,
            crud_location_read_min.locationnameuuid,
            crud_location_read_min.locationdisplaynameuuid,
            crud_location_read_min.locationscanid,
            crud_location_read_min.locationcreateddate,
            crud_location_read_min.locationmodifieddate,
            crud_location_read_min.locationmodifiedbyuuid,
            crud_location_read_min.locationstartdate,
            crud_location_read_min.locationenddate,
            crud_location_read_min.locationexternalid,
            crud_location_read_min.locationexternalsystementityuuid,
            crud_location_read_min.locationcornerstoneorder,
            crud_location_read_min.locationlatitude,
            crud_location_read_min.locationlongitude,
            crud_location_read_min.locationradius,
            crud_location_read_min.locationtimezone,
            crud_location_read_min.locationtagentityuuid,
            crud_location_read_min.locationsenddeleted,
            crud_location_read_min.locationsenddrafts,
            crud_location_read_min.locationsendinactive
           FROM entity.crud_location_read_min(NULL::uuid, NULL::uuid, NULL::uuid, NULL::uuid, true, NULL::uuid, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_location_read_min(languagetranslationtypeentityuuid, locationid, locationuuid, locationentityuuid, locationownerentityuuid, locationparententityuuid, locationcornerstoneentityuuid, locationcustomerid, locationcustomeruuid, locationcustomerentityuuid, locationnameuuid, locationdisplaynameuuid, locationscanid, locationcreateddate, locationmodifieddate, locationmodifiedbyuuid, locationstartdate, locationenddate, locationexternalid, locationexternalsystementityuuid, locationcornerstoneorder, locationlatitude, locationlongitude, locationradius, locationtimezone, locationtagentityuuid, locationsenddeleted, locationsenddrafts, locationsendinactive)) parent ON parent.locationentityuuid = location.locationparententityuuid
     LEFT JOIN languagemaster lm ON lm.languagemasteruuid = parent.locationnameuuid
     LEFT JOIN languagetranslations lt ON lt.languagetranslationmasterid = (( SELECT languagemaster.languagemasterid
           FROM languagemaster
          WHERE languagemaster.languagemasteruuid = parent.locationnameuuid)) AND lt.languagetranslationtypeid = (( SELECT crud_systag_read_min.systagid
           FROM entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61'::uuid, NULL::uuid, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid)), NULL::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid) crud_systag_read_min(languagetranslationtypeentityuuid, systagid, systaguuid, systagentityuuid, systagcustomerid, systagcustomeruuid, systagcustomerentityuuid, systagnameuuid, systagdisplaynameuuid, systagtype, systagcreateddate, systagmodifieddate, systagstartdate, systagenddate, systagexternalid, systagexternalsystementityuuid, systagmodifiedbyuuid, systagabbreviationentityuuid, systagparententityuuid, systagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)))
  WHERE (location.locationownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.location IS '
## Location

A description of what an location is and why it is used

### get {baseUrl}/location

A bunch of comments explaining get

### del {baseUrl}/location

A bunch of comments explaining del

### patch {baseUrl}/location

A bunch of comments explaining patch
';

CREATE TRIGGER create_location_tg INSTEAD OF INSERT ON api.location FOR EACH ROW EXECUTE FUNCTION api.create_location();
CREATE TRIGGER update_location_tg INSTEAD OF UPDATE ON api.location FOR EACH ROW EXECUTE FUNCTION api.update_location();

GRANT INSERT ON api.location TO authenticated;
GRANT SELECT ON api.location TO authenticated;
GRANT UPDATE ON api.location TO authenticated;

-- Type: VIEW ; Name: reason_code; Owner: tendreladmin

CREATE OR REPLACE VIEW api.reason_code AS
 SELECT custag.custagentityuuid AS id,
    custag.custagid AS legacy_id,
    custag.custaguuid AS legacy_uuid,
    custag.custagownerentityuuid AS owner,
    custag.custagownerentityname AS owner_name,
    custag.custagparententityuuid AS parent,
    custag.custagparentname AS parent_name,
    custag.custagcornerstoneentityid AS cornerstone,
    custag.custagnameuuid AS name_id,
    custag.custagname AS name,
    custag.custagdisplaynameuuid AS displayname_id,
    custag.custagdisplayname AS displayname,
    custag.custagtype AS type,
    custag.custagcreateddate AS created_at,
    custag.custagmodifieddate AS updated_at,
    custag.custagstartdate AS activated_at,
    custag.custagenddate AS deactivated_at,
    custag.custagexternalid AS external_id,
    custag.custagexternalsystementityuuid AS external_system,
    custag.custagmodifiedbyuuid AS modified_by,
    custag.custagorder AS _order,
    custag.systagsenddeleted AS _deleted,
    custag.systagsenddrafts AS _draft,
    custag.systagsendinactive AS _active,
    wtc.worktemplateconstraintid AS work_template_constraint,
    wt.id AS work_template,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS work_template_name
   FROM ( SELECT crud_custag_read_api.languagetranslationtypeentityuuid,
            crud_custag_read_api.custagid,
            crud_custag_read_api.custaguuid,
            crud_custag_read_api.custagentityuuid,
            crud_custag_read_api.custagownerentityuuid,
            crud_custag_read_api.custagownerentityname,
            crud_custag_read_api.custagparententityuuid,
            crud_custag_read_api.custagparentname,
            crud_custag_read_api.custagcornerstoneentityid,
            crud_custag_read_api.custagcustomerid,
            crud_custag_read_api.custagcustomeruuid,
            crud_custag_read_api.custagcustomerentityuuid,
            crud_custag_read_api.custagcustomername,
            crud_custag_read_api.custagnameuuid,
            crud_custag_read_api.custagname,
            crud_custag_read_api.custagdisplaynameuuid,
            crud_custag_read_api.custagdisplayname,
            crud_custag_read_api.custagtype,
            crud_custag_read_api.custagcreateddate,
            crud_custag_read_api.custagmodifieddate,
            crud_custag_read_api.custagstartdate,
            crud_custag_read_api.custagenddate,
            crud_custag_read_api.custagexternalid,
            crud_custag_read_api.custagexternalsystementityuuid,
            crud_custag_read_api.custagexternalsystemenname,
            crud_custag_read_api.custagmodifiedbyuuid,
            crud_custag_read_api.custagabbreviationentityuuid,
            crud_custag_read_api.custagabbreviationname,
            crud_custag_read_api.custagorder,
            crud_custag_read_api.systagsenddeleted,
            crud_custag_read_api.systagsenddrafts,
            crud_custag_read_api.systagsendinactive
           FROM entity.crud_custag_read_api(ARRAY( SELECT util_get_onwership.get_ownership
                   FROM _api.util_get_onwership() util_get_onwership(get_ownership)), NULL::uuid, NULL::uuid, 'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b'::uuid, false, NULL::boolean, NULL::boolean, NULL::boolean, ( SELECT util_user_details.get_languagetypeentityuuid
                   FROM _api.util_user_details() util_user_details(get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid))) crud_custag_read_api(languagetranslationtypeentityuuid, custagid, custaguuid, custagentityuuid, custagownerentityuuid, custagownerentityname, custagparententityuuid, custagparentname, custagcornerstoneentityid, custagcustomerid, custagcustomeruuid, custagcustomerentityuuid, custagcustomername, custagnameuuid, custagname, custagdisplaynameuuid, custagdisplayname, custagtype, custagcreateddate, custagmodifieddate, custagstartdate, custagenddate, custagexternalid, custagexternalsystementityuuid, custagexternalsystemenname, custagmodifiedbyuuid, custagabbreviationentityuuid, custagabbreviationname, custagorder, systagsenddeleted, systagsenddrafts, systagsendinactive)) custag
     LEFT JOIN worktemplateconstraint wtc ON wtc.worktemplateconstraintconstrainedtypeid = 'systag_4bbc3e18-de10-4f93-aabb-b1d051a2923d'::text AND wtc.worktemplateconstraintconstraintid = custag.custaguuid
     LEFT JOIN worktemplate wt ON wtc.worktemplateconstrainttemplateid = wt.id
     LEFT JOIN languagemaster lm ON wt.worktemplatenameid = lm.languagemasterid
     LEFT JOIN languagetranslations lt ON lm.languagemasterid = lt.languagetranslationmasterid
  WHERE (custag.custagownerentityuuid IN ( SELECT util_get_onwership.get_ownership
           FROM _api.util_get_onwership() util_get_onwership(get_ownership)));

COMMENT ON VIEW api.reason_code IS '
## Reason Code

A description of what an entity tempalte is and why it is used

### get {baseUrl}/custag

A bunch of comments explaining get

### del {baseUrl}/custag

A bunch of comments explaining del

### patch {baseUrl}/custag

A bunch of comments explaining patch
';

GRANT INSERT ON api.reason_code TO authenticated;
GRANT SELECT ON api.reason_code TO authenticated;
GRANT UPDATE ON api.reason_code TO authenticated;

-- Type: VIEW ; Name: view_custag; Owner: tendreladmin

CREATE OR REPLACE VIEW view_custag AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    custag.custagabbreviationid,
    custag.custagcreateddate,
    custag.custagcustomerid,
    custag.custagcustomeruuid,
    custag.custagenddate,
    custag.custagexternalid,
    custag.custagexternalsystemid,
    custag.custagid,
    custag.custaguuid,
    custag.custagmodifiedby,
    custag.custagmodifieddate,
    custag.custagnameid,
    custag.custagorder,
    custag.custagstartdate,
    custag.custagsystagid,
    custag.custagsystaguuid,
    custag.custagtype,
    COALESCE(custagabbr.languagetranslationvalue, lmabbr.languagemastersource) AS custagabbreviation,
    COALESCE(custagname.languagetranslationvalue, custag.custagtype) AS custagname
   FROM custag
     JOIN customerrequestedlanguage crl ON custag.custagcustomerid = crl.customerrequestedlanguagecustomerid
     LEFT JOIN languagetranslations custagname ON custag.custagnameid = custagname.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = custagname.languagetranslationtypeid
     LEFT JOIN languagemaster lmabbr ON custag.custagabbreviationid = lmabbr.languagemasterid
     LEFT JOIN languagetranslations custagabbr ON custag.custagabbreviationid = custagabbr.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = custagabbr.languagetranslationtypeid;


GRANT INSERT ON view_custag TO authenticated;
GRANT SELECT ON view_custag TO authenticated;
GRANT UPDATE ON view_custag TO authenticated;
GRANT DELETE ON view_custag TO graphql;
GRANT INSERT ON view_custag TO graphql;
GRANT REFERENCES ON view_custag TO graphql;
GRANT SELECT ON view_custag TO graphql;
GRANT TRIGGER ON view_custag TO graphql;
GRANT TRUNCATE ON view_custag TO graphql;
GRANT UPDATE ON view_custag TO graphql;

-- Type: VIEW ; Name: view_activecustomer; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activecustomer AS
 SELECT languagetranslationtypeid,
    customercreateddate,
    customerenddate,
    customerexternalid,
    customerexternalsystemid,
    customerexternalsystemuuid,
    customerid,
    customeruuid,
    customermodifiedby,
    customermodifieddate,
    customername,
    customerstartdate,
    customertypeuuid
   FROM view_customer
  WHERE customerenddate IS NULL OR customerenddate > now();


GRANT INSERT ON view_activecustomer TO authenticated;
GRANT SELECT ON view_activecustomer TO authenticated;
GRANT UPDATE ON view_activecustomer TO authenticated;
GRANT DELETE ON view_activecustomer TO graphql;
GRANT INSERT ON view_activecustomer TO graphql;
GRANT REFERENCES ON view_activecustomer TO graphql;
GRANT SELECT ON view_activecustomer TO graphql;
GRANT TRIGGER ON view_activecustomer TO graphql;
GRANT TRUNCATE ON view_activecustomer TO graphql;
GRANT UPDATE ON view_activecustomer TO graphql;

-- Type: VIEW ; Name: view_activecustomerrequestedlanguage; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activecustomerrequestedlanguage AS
 SELECT customerrequestedlanguagelanguageid,
    customerrequestedlanguagecreateddate,
    customerrequestedlanguagecustomerid,
    customerrequestedlanguageenddate,
    customerrequestedlanguageexternalid,
    customerrequestedlanguageexternalsystemid,
    customerrequestedlanguageid,
    customerrequestedlanguagemodifiedby,
    customerrequestedlanguagemodifieddate,
    customerrequestedlanguagestartdate
   FROM view_customerrequestedlanguage
  WHERE customerrequestedlanguageenddate IS NULL OR customerrequestedlanguageenddate > now();


GRANT INSERT ON view_activecustomerrequestedlanguage TO authenticated;
GRANT SELECT ON view_activecustomerrequestedlanguage TO authenticated;
GRANT UPDATE ON view_activecustomerrequestedlanguage TO authenticated;
GRANT DELETE ON view_activecustomerrequestedlanguage TO graphql;
GRANT INSERT ON view_activecustomerrequestedlanguage TO graphql;
GRANT REFERENCES ON view_activecustomerrequestedlanguage TO graphql;
GRANT SELECT ON view_activecustomerrequestedlanguage TO graphql;
GRANT TRIGGER ON view_activecustomerrequestedlanguage TO graphql;
GRANT TRUNCATE ON view_activecustomerrequestedlanguage TO graphql;
GRANT UPDATE ON view_activecustomerrequestedlanguage TO graphql;

-- Type: VIEW ; Name: view_location; Owner: tendreladmin

CREATE OR REPLACE VIEW view_location AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    l.locationcategoryid,
    l.locationcornerstoneid,
    l.locationcornerstoneorder,
    l.locationcreatedby,
    l.locationcreateddate,
    l.locationcustomerid,
    l.locationenddate,
    l.locationexternalid,
    l.locationexternalsystemid,
    l.locationid,
    l.locationiscornerstone,
    l.locationistop,
    l.locationlookupname,
    l.locationlatitude,
    l.locationlongitude,
    l.locationradius,
    l.locationmodifiedby,
    l.locationmodifieddate,
    l.locationnameid,
    l.locationparentid,
    l.locationscanid,
    l.locationsiteid,
    l.locationstartdate,
    l.locationtimezone,
    l.locationuuid,
    COALESCE(t_name.languagetranslationvalue, m_name.languagemastersource) AS locationfullname
   FROM location l
     JOIN customerrequestedlanguage crl ON l.locationcustomerid = crl.customerrequestedlanguagecustomerid
     JOIN languagemaster m_name ON l.locationnameid = m_name.languagemasterid
     LEFT JOIN languagetranslations t_name ON crl.customerrequestedlanguagelanguageid = t_name.languagetranslationtypeid AND l.locationnameid = t_name.languagetranslationmasterid;


GRANT INSERT ON view_location TO authenticated;
GRANT SELECT ON view_location TO authenticated;
GRANT UPDATE ON view_location TO authenticated;
GRANT DELETE ON view_location TO graphql;
GRANT INSERT ON view_location TO graphql;
GRANT REFERENCES ON view_location TO graphql;
GRANT SELECT ON view_location TO graphql;
GRANT TRIGGER ON view_location TO graphql;
GRANT TRUNCATE ON view_location TO graphql;
GRANT UPDATE ON view_location TO graphql;

-- Type: VIEW ; Name: view_systag; Owner: tendreladmin

CREATE OR REPLACE VIEW view_systag AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    systag.systagabbreviationid,
    systag.systagcreateddate,
    systag.systagenddate,
    systag.systagexternalid,
    systag.systagexternalsystemid,
    systag.systagid,
    systag.systaguuid,
    systag.systagmodifiedby,
    systag.systagmodifieddate,
    systag.systagnameid,
    systag.systagorder,
    systag.systagparentid,
    systag.systagstartdate,
    systag.systagtype,
    COALESCE(systagabbr.languagetranslationvalue, lmabbr.languagemastersource) AS systagabbreviation,
    COALESCE(systagname.languagetranslationvalue, systag.systagtype) AS systagname
   FROM systag
     JOIN customerrequestedlanguage crl ON 0 = crl.customerrequestedlanguagecustomerid
     LEFT JOIN languagetranslations systagname ON crl.customerrequestedlanguagelanguageid = systagname.languagetranslationtypeid AND systag.systagnameid = systagname.languagetranslationmasterid
     LEFT JOIN languagemaster lmabbr ON systag.systagabbreviationid = lmabbr.languagemasterid
     LEFT JOIN languagetranslations systagabbr ON systag.systagabbreviationid = systagabbr.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = systagabbr.languagetranslationtypeid;


GRANT INSERT ON view_systag TO authenticated;
GRANT SELECT ON view_systag TO authenticated;
GRANT UPDATE ON view_systag TO authenticated;
GRANT DELETE ON view_systag TO graphql;
GRANT INSERT ON view_systag TO graphql;
GRANT REFERENCES ON view_systag TO graphql;
GRANT SELECT ON view_systag TO graphql;
GRANT TRIGGER ON view_systag TO graphql;
GRANT TRUNCATE ON view_systag TO graphql;
GRANT UPDATE ON view_systag TO graphql;

-- Type: VIEW ; Name: view_activeworkdescription; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkdescription AS
 SELECT languagetranslationtypeid,
    workdescriptioncreateddate,
    workdescriptioncustomerid,
    workdescriptionenddate,
    workdescriptionexternalid,
    workdescriptionexternalsystemid,
    workdescriptionid,
    workdescriptionlanguagemasterid,
    workdescriptionlanguagetypeid,
    workdescriptionmodifiedby,
    workdescriptionmodifieddate,
    workdescriptionstartdate,
    workdescriptionworktemplateid,
    worktemplatedescription,
    worktemplatesoplink
   FROM view_workdescription
  WHERE workdescriptionenddate IS NULL OR workdescriptionenddate > now();


GRANT INSERT ON view_activeworkdescription TO authenticated;
GRANT SELECT ON view_activeworkdescription TO authenticated;
GRANT UPDATE ON view_activeworkdescription TO authenticated;
GRANT DELETE ON view_activeworkdescription TO graphql;
GRANT INSERT ON view_activeworkdescription TO graphql;
GRANT REFERENCES ON view_activeworkdescription TO graphql;
GRANT SELECT ON view_activeworkdescription TO graphql;
GRANT TRIGGER ON view_activeworkdescription TO graphql;
GRANT TRUNCATE ON view_activeworkdescription TO graphql;
GRANT UPDATE ON view_activeworkdescription TO graphql;

-- Type: VIEW ; Name: view_activeworker; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworker AS
 SELECT workeraddressid,
    workercreateddate,
    workeremail,
    workerenddate,
    workerexternalid,
    workerexternalsystemid,
    workerexternalsystemuuid,
    workerfirstname,
    workerfullname,
    workerid,
    workeruuid,
    workeridentitysystemuuid,
    workerlanguageid,
    workerlastname,
    workermodifiedby,
    workermodifieddate,
    workerpassword,
    workerphonenumber,
    workerstartdate,
    workerusername,
    workerdatacomplete,
    workeridentityid,
    workeridentitysystemid,
    workergeneratedname
   FROM view_worker
  WHERE workerenddate IS NULL OR workerenddate > now();


GRANT INSERT ON view_activeworker TO authenticated;
GRANT SELECT ON view_activeworker TO authenticated;
GRANT UPDATE ON view_activeworker TO authenticated;
GRANT DELETE ON view_activeworker TO graphql;
GRANT INSERT ON view_activeworker TO graphql;
GRANT REFERENCES ON view_activeworker TO graphql;
GRANT SELECT ON view_activeworker TO graphql;
GRANT TRIGGER ON view_activeworker TO graphql;
GRANT TRUNCATE ON view_activeworker TO graphql;
GRANT UPDATE ON view_activeworker TO graphql;

-- Type: VIEW ; Name: view_workerinstance; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workerinstance AS
 SELECT wi.workerinstancecreateddate,
    wi.workerinstancecustomerid,
    wi.workerinstancecustomeruuid,
    wi.workerinstanceenddate,
    wi.workerinstanceexternalid,
    wi.workerinstanceexternalsystemid,
    wi.workerinstanceid,
    wi.workerinstancelanguageid,
    wi.workerinstancelanguageuuid,
    wi.workerinstancemodifiedby,
    wi.workerinstancemodifieddate,
    w.workerfullname AS workerinstancename,
    wi.workerinstancescanid,
    wi.workerinstancestartdate,
    wi.workerinstanceuuid,
    wi.workerinstanceuserroleid,
    wi.workerinstanceuserroleuuid,
    wi.workerinstanceworkerid,
    wi.workerinstanceworkeruuid,
    wi.workerinstancedatacomplete
   FROM workerinstance wi
     LEFT JOIN view_worker w ON wi.workerinstanceworkerid = w.workerid;


GRANT INSERT ON view_workerinstance TO authenticated;
GRANT SELECT ON view_workerinstance TO authenticated;
GRANT UPDATE ON view_workerinstance TO authenticated;
GRANT DELETE ON view_workerinstance TO graphql;
GRANT INSERT ON view_workerinstance TO graphql;
GRANT REFERENCES ON view_workerinstance TO graphql;
GRANT SELECT ON view_workerinstance TO graphql;
GRANT TRIGGER ON view_workerinstance TO graphql;
GRANT TRUNCATE ON view_workerinstance TO graphql;
GRANT UPDATE ON view_workerinstance TO graphql;

-- Type: VIEW ; Name: view_worktemplate; Owner: tendreladmin

CREATE OR REPLACE VIEW view_worktemplate AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    wd.worktemplatedescription,
    wd.worktemplatesoplink,
    wt.id,
    wt.worktemplateallowondemand,
    wt.worktemplatecreateddate,
    wt.worktemplatecustomerid,
    wt.worktemplateenddate,
    wt.worktemplateexpectedduration,
    wt.worktemplateexpecteddurationtypeid,
    wt.worktemplateexternalid,
    wt.worktemplateexternalsystemid,
    wt.worktemplateid,
    wt.worktemplateisauditable,
    location_type.custagid AS worktemplatelocationtypeid,
    wt.worktemplatemodifiedby,
    wt.worktemplatemodifieddate,
    wt.worktemplatenameid,
    wt.worktemplateorder,
    wt.worktemplatescanid,
    wt.worktemplatesiteid,
    wt.worktemplatestartdate,
    wt.worktemplateworkfrequencyid,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS worktemplatename
   FROM worktemplate wt
     JOIN customerrequestedlanguage crl ON wt.worktemplatecustomerid = crl.customerrequestedlanguagecustomerid
     LEFT JOIN worktemplateconstraint wtc ON wt.id = wtc.worktemplateconstrainttemplateid AND wtc.worktemplateconstraintresultid IS NULL AND wtc.worktemplateconstraintconstrainedtypeid = (( SELECT systag.systaguuid
           FROM systag
          WHERE systag.systagparentid = 849 AND systag.systagtype = 'Location'::text))
     LEFT JOIN custag location_type ON wtc.worktemplateconstraintconstraintid = location_type.custaguuid
     LEFT JOIN languagetranslations lt ON crl.customerrequestedlanguagelanguageid = lt.languagetranslationtypeid AND wt.worktemplatenameid = lt.languagetranslationmasterid AND wt.worktemplatecustomerid = lt.languagetranslationcustomerid
     LEFT JOIN languagemaster lm ON wt.worktemplatenameid = lm.languagemasterid AND wt.worktemplatecustomerid = lm.languagemastercustomerid
     LEFT JOIN view_workdescription wd ON crl.customerrequestedlanguagelanguageid = wd.languagetranslationtypeid AND wt.worktemplateid = wd.workdescriptionworktemplateid AND wt.worktemplatecustomerid = wd.workdescriptioncustomerid;


GRANT INSERT ON view_worktemplate TO authenticated;
GRANT SELECT ON view_worktemplate TO authenticated;
GRANT UPDATE ON view_worktemplate TO authenticated;
GRANT DELETE ON view_worktemplate TO graphql;
GRANT INSERT ON view_worktemplate TO graphql;
GRANT REFERENCES ON view_worktemplate TO graphql;
GRANT SELECT ON view_worktemplate TO graphql;
GRANT TRIGGER ON view_worktemplate TO graphql;
GRANT TRUNCATE ON view_worktemplate TO graphql;
GRANT UPDATE ON view_worktemplate TO graphql;

-- Type: VIEW ; Name: view_activeworktemplatenexttemplate; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworktemplatenexttemplate AS
 SELECT worktemplatenexttemplatecreateddate,
    worktemplatenexttemplatecustomerid,
    worktemplatenexttemplateenddate,
    worktemplatenexttemplateexternalid,
    worktemplatenexttemplateexternalsystemid,
    worktemplatenexttemplateid,
    worktemplatenexttemplatemodifiedby,
    worktemplatenexttemplatemodifieddate,
    worktemplatenexttemplatenexttemplateid,
    worktemplatenexttemplateprevioustemplateid,
    worktemplatenexttemplatesiteid,
    worktemplatenexttemplatestartdate,
    worktemplatenexttemplatetypeid,
    worktemplatenexttemplateviastatuschange,
    worktemplatenexttemplateviastatuschangeid,
    worktemplatenexttemplateviaworkresultcontstraintid,
    worktemplatenexttemplateviaworkresultid,
    worktemplatenexttemplateviaworkresultvalue
   FROM view_worktemplatenexttemplate
  WHERE worktemplatenexttemplateenddate IS NULL OR worktemplatenexttemplateenddate > now();


GRANT INSERT ON view_activeworktemplatenexttemplate TO authenticated;
GRANT SELECT ON view_activeworktemplatenexttemplate TO authenticated;
GRANT UPDATE ON view_activeworktemplatenexttemplate TO authenticated;
GRANT DELETE ON view_activeworktemplatenexttemplate TO graphql;
GRANT INSERT ON view_activeworktemplatenexttemplate TO graphql;
GRANT REFERENCES ON view_activeworktemplatenexttemplate TO graphql;
GRANT SELECT ON view_activeworktemplatenexttemplate TO graphql;
GRANT TRIGGER ON view_activeworktemplatenexttemplate TO graphql;
GRANT TRUNCATE ON view_activeworktemplatenexttemplate TO graphql;
GRANT UPDATE ON view_activeworktemplatenexttemplate TO graphql;
ALTER TABLE apikey ALTER apikeyid SET DEFAULT nextval('apikey_apikeyid_seq'::regclass);
ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypesystaguuid_fkey
      FOREIGN KEY (worktemplatetypesystaguuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstrainttemplateid_fkey
      FOREIGN KEY (worktemplateconstrainttemplateid) REFERENCES worktemplate(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintconstraintid_fkey
      FOREIGN KEY (worktemplateconstraintconstraintid) REFERENCES custag(custaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customer ADD CONSTRAINT customer_customerexternalsystemuuid_fkey
      FOREIGN KEY (customerexternalsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worker ADD CONSTRAINT worker_workerexternalsystemuuid_fkey
      FOREIGN KEY (workerexternalsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigmodifiedby_fkey
      FOREIGN KEY (customerconfigmodifiedby) REFERENCES workerinstance(workerinstanceuuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintcustomeruuid_fkey
      FOREIGN KEY (worktemplateconstraintcustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypecustomeruuid_fkey
      FOREIGN KEY (worktemplatetypecustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordmodifiedby_fkey
      FOREIGN KEY (customerbillingrecordmodifiedby) REFERENCES workerinstance(workerinstanceuuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE custag ADD CONSTRAINT custag_custagcustomeruuid_fkey
      FOREIGN KEY (custagcustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigcustomeruuid_fkey
      FOREIGN KEY (customerconfigcustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worker ADD CONSTRAINT worker_workeridentitysystemuuid_fkey
      FOREIGN KEY (workeridentitysystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypeworktemplateuuid_fkey
      FOREIGN KEY (worktemplatetypeworktemplateuuid) REFERENCES worktemplate(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE entity.entityfield ADD CONSTRAINT entityfield_entityfieldmodifiedbyuuid_fkey
      FOREIGN KEY (entityfieldmodifiedbyuuid) REFERENCES workerinstance(workerinstanceuuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintconstrainedty_fkey
      FOREIGN KEY (worktemplateconstraintconstrainedtypeid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE entity.entitytemplate ADD CONSTRAINT entitytemplatemodifiedbyuuid_workerinstanceuuid_fk
      FOREIGN KEY (entitytemplatemodifiedbyuuid) REFERENCES workerinstance(workerinstanceuuid) NOT VALID;

ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordbillingsystemuu_fkey
      FOREIGN KEY (customerbillingrecordbillingsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordcustomertypeuui_fkey
      FOREIGN KEY (customerbillingrecordcustomertypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordstatusuuid_fkey
      FOREIGN KEY (customerbillingrecordstatusuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigtypeuuid_fkey
      FOREIGN KEY (customerconfigtypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigvaluetypeuuid_fkey
      FOREIGN KEY (customerconfigvaluetypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintresultid_fkey
      FOREIGN KEY (worktemplateconstraintresultid) REFERENCES workresult(id) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceworkeruuid_fkey
      FOREIGN KEY (workerinstanceworkeruuid) REFERENCES worker(workeruuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customerconfig ADD CONSTRAINT customerconfig_customerconfigsiteuuid_fkey
      FOREIGN KEY (customerconfigsiteuuid) REFERENCES location(locationuuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceexternalsystemuuid_fkey
      FOREIGN KEY (workerinstanceexternalsystemuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancelanguageuuid_fkey
      FOREIGN KEY (workerinstancelanguageuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customer ADD CONSTRAINT customer_customerlanguagetypeuuid_fkey
      FOREIGN KEY (customerlanguagetypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customer ADD CONSTRAINT customer_customertypeuuid_fkey
      FOREIGN KEY (customertypeuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancecustomeruuid_fkey
      FOREIGN KEY (workerinstancecustomeruuid) REFERENCES customer(customeruuid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE entity.entityinstance ADD CONSTRAINT entityinstance_entityinstancemodifiedbyuuid_fk
      FOREIGN KEY (entityinstancemodifiedbyuuid) REFERENCES workerinstance(workerinstanceuuid) NOT VALID;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceuserroleuuid_fkey
      FOREIGN KEY (workerinstanceuserroleuuid) REFERENCES systag(systaguuid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatenextlocat_fkey
      FOREIGN KEY (worktemplatenexttemplatenextlocationid) REFERENCES location(locationuuid);

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateprevlocat_fkey
      FOREIGN KEY (worktemplatenexttemplateprevlocationid) REFERENCES location(locationuuid);

ALTER TABLE entity.entityfieldinstance ADD CONSTRAINT efi_entityfieldinstancemodifiedbyuuid_fk
      FOREIGN KEY (entityfieldinstancemodifiedbyuuid) REFERENCES workerinstance(workerinstanceuuid) NOT VALID;


-- Type: FUNCTION ; Name: api.delete_customer_requested_language(uuid,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_customer_requested_language(owner uuid, id text)
 RETURNS SETOF api.customer_requested_language
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
	templanguagetypeid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
  
select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
		call entity.crud_customerrequestedlanguage_delete(
			create_customerownerentityuuid := owner,
			create_language_id := id,
			create_modifiedbyid := ins_userid
	);
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.customer_requested_language t
    where t.owner = $1  and 
		t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_customer_requested_language(uuid,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_customer_requested_language(uuid,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_customer_requested_language(uuid,text) TO authenticated;

-- Type: VIEW ; Name: view_activecustag; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activecustag AS
 SELECT languagetranslationtypeid,
    custagabbreviationid,
    custagcreateddate,
    custagcustomerid,
    custagcustomeruuid,
    custagenddate,
    custagexternalid,
    custagexternalsystemid,
    custagid,
    custaguuid,
    custagmodifiedby,
    custagmodifieddate,
    custagnameid,
    custagorder,
    custagstartdate,
    custagsystagid,
    custagsystaguuid,
    custagtype,
    custagabbreviation,
    custagname
   FROM view_custag
  WHERE custagenddate IS NULL OR custagenddate > now();


GRANT INSERT ON view_activecustag TO authenticated;
GRANT SELECT ON view_activecustag TO authenticated;
GRANT UPDATE ON view_activecustag TO authenticated;
GRANT DELETE ON view_activecustag TO graphql;
GRANT INSERT ON view_activecustag TO graphql;
GRANT REFERENCES ON view_activecustag TO graphql;
GRANT SELECT ON view_activecustag TO graphql;
GRANT TRIGGER ON view_activecustag TO graphql;
GRANT TRUNCATE ON view_activecustag TO graphql;
GRANT UPDATE ON view_activecustag TO graphql;

-- Type: VIEW ; Name: view_activelocation; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activelocation AS
 SELECT languagetranslationtypeid,
    locationcategoryid,
    locationcornerstoneid,
    locationcornerstoneorder,
    locationcreatedby,
    locationcreateddate,
    locationcustomerid,
    locationenddate,
    locationexternalid,
    locationexternalsystemid,
    locationid,
    locationiscornerstone,
    locationistop,
    locationlookupname,
    locationlatitude,
    locationlongitude,
    locationradius,
    locationmodifiedby,
    locationmodifieddate,
    locationnameid,
    locationparentid,
    locationscanid,
    locationsiteid,
    locationstartdate,
    locationtimezone,
    locationuuid,
    locationfullname
   FROM view_location
  WHERE locationenddate IS NULL OR locationenddate > now();


GRANT INSERT ON view_activelocation TO authenticated;
GRANT SELECT ON view_activelocation TO authenticated;
GRANT UPDATE ON view_activelocation TO authenticated;
GRANT DELETE ON view_activelocation TO graphql;
GRANT INSERT ON view_activelocation TO graphql;
GRANT REFERENCES ON view_activelocation TO graphql;
GRANT SELECT ON view_activelocation TO graphql;
GRANT TRIGGER ON view_activelocation TO graphql;
GRANT TRUNCATE ON view_activelocation TO graphql;
GRANT UPDATE ON view_activelocation TO graphql;

-- Type: VIEW ; Name: view_resource; Owner: tendreladmin

CREATE OR REPLACE VIEW view_resource AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    r.resourcecreateddate,
    r.resourcecustomerid,
    r.resourcecustomertypeid,
    custag.custagname AS resourcecustomertypename,
    r.resourceenddate,
    r.resourceexternalid,
    r.resourceexternalsystemid,
    r.resourceid,
    r.resourcelookupname,
    r.resourcemodifiedby,
    r.resourcemodifieddate,
    r.resourcenameid,
    r.resourceorder,
    r.resourcescanid,
    r.resourcesiteid,
    r.resourcestartdate,
    r.resourcetypeid,
    systag.systagname AS resourcetypename,
    r.resourceuuid,
    COALESCE(t_name.languagetranslationvalue, m_name.languagemastersource) AS resourcefullname
   FROM resource r
     JOIN customerrequestedlanguage crl ON r.resourcecustomerid = crl.customerrequestedlanguagecustomerid
     JOIN languagemaster m_name ON r.resourcenameid = m_name.languagemasterid
     LEFT JOIN languagetranslations t_name ON crl.customerrequestedlanguagelanguageid = t_name.languagetranslationtypeid AND r.resourcenameid = t_name.languagetranslationmasterid
     LEFT JOIN view_systag systag ON r.resourcetypeid = systag.systagid AND crl.customerrequestedlanguagelanguageid = systag.languagetranslationtypeid
     LEFT JOIN view_custag custag ON r.resourcecustomertypeid = custag.custagid AND crl.customerrequestedlanguagelanguageid = custag.languagetranslationtypeid AND r.resourcecustomerid = custag.custagcustomerid;


GRANT INSERT ON view_resource TO authenticated;
GRANT SELECT ON view_resource TO authenticated;
GRANT UPDATE ON view_resource TO authenticated;
GRANT DELETE ON view_resource TO graphql;
GRANT INSERT ON view_resource TO graphql;
GRANT REFERENCES ON view_resource TO graphql;
GRANT SELECT ON view_resource TO graphql;
GRANT TRIGGER ON view_resource TO graphql;
GRANT TRUNCATE ON view_resource TO graphql;
GRANT UPDATE ON view_resource TO graphql;

-- Type: VIEW ; Name: view_activesystag; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activesystag AS
 SELECT languagetranslationtypeid,
    systagabbreviationid,
    systagcreateddate,
    systagenddate,
    systagexternalid,
    systagexternalsystemid,
    systagid,
    systaguuid,
    systagmodifiedby,
    systagmodifieddate,
    systagnameid,
    systagorder,
    systagparentid,
    systagstartdate,
    systagtype,
    systagabbreviation,
    systagname
   FROM view_systag
  WHERE systagenddate IS NULL OR systagenddate > now();


GRANT INSERT ON view_activesystag TO authenticated;
GRANT SELECT ON view_activesystag TO authenticated;
GRANT UPDATE ON view_activesystag TO authenticated;
GRANT DELETE ON view_activesystag TO graphql;
GRANT INSERT ON view_activesystag TO graphql;
GRANT REFERENCES ON view_activesystag TO graphql;
GRANT SELECT ON view_activesystag TO graphql;
GRANT TRIGGER ON view_activesystag TO graphql;
GRANT TRUNCATE ON view_activesystag TO graphql;
GRANT UPDATE ON view_activesystag TO graphql;

-- Type: VIEW ; Name: view_activeworkerinstance; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkerinstance AS
 SELECT workerinstancecreateddate,
    workerinstancecustomerid,
    workerinstancecustomeruuid,
    workerinstanceenddate,
    workerinstanceexternalid,
    workerinstanceexternalsystemid,
    workerinstanceid,
    workerinstancelanguageid,
    workerinstancelanguageuuid,
    workerinstancemodifiedby,
    workerinstancemodifieddate,
    workerinstancename,
    workerinstancescanid,
    workerinstancestartdate,
    workerinstanceuuid,
    workerinstanceuserroleid,
    workerinstanceuserroleuuid,
    workerinstanceworkerid,
    workerinstanceworkeruuid,
    workerinstancedatacomplete
   FROM view_workerinstance
  WHERE workerinstanceenddate IS NULL OR workerinstanceenddate > now();


GRANT INSERT ON view_activeworkerinstance TO authenticated;
GRANT SELECT ON view_activeworkerinstance TO authenticated;
GRANT UPDATE ON view_activeworkerinstance TO authenticated;
GRANT DELETE ON view_activeworkerinstance TO graphql;
GRANT INSERT ON view_activeworkerinstance TO graphql;
GRANT REFERENCES ON view_activeworkerinstance TO graphql;
GRANT SELECT ON view_activeworkerinstance TO graphql;
GRANT TRIGGER ON view_activeworkerinstance TO graphql;
GRANT TRUNCATE ON view_activeworkerinstance TO graphql;
GRANT UPDATE ON view_activeworkerinstance TO graphql;

-- Type: VIEW ; Name: view_workfrequency; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workfrequency AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    wf.workfrequencycreateddate,
    wf.workfrequencycustomerid,
    wf.workfrequencyenddate,
    wf.workfrequencyexternalid,
    wf.workfrequencyexternalsystemid,
    wf.workfrequencyid,
    wf.workfrequencymodifiedby,
    wf.workfrequencymodifieddate,
    wf.workfrequencystartdate,
    wf.workfrequencytypeid,
    frequencytype.systagname AS workfrequencytypename,
    wf.workfrequencyvalue,
    wf.workfrequencyworktemplateid
   FROM workfrequency wf
     JOIN customerrequestedlanguage crl ON wf.workfrequencycustomerid = crl.customerrequestedlanguagecustomerid
     LEFT JOIN view_systag frequencytype ON crl.customerrequestedlanguagelanguageid = frequencytype.languagetranslationtypeid AND wf.workfrequencytypeid = frequencytype.systagid;


GRANT INSERT ON view_workfrequency TO authenticated;
GRANT SELECT ON view_workfrequency TO authenticated;
GRANT UPDATE ON view_workfrequency TO authenticated;
GRANT DELETE ON view_workfrequency TO graphql;
GRANT INSERT ON view_workfrequency TO graphql;
GRANT REFERENCES ON view_workfrequency TO graphql;
GRANT SELECT ON view_workfrequency TO graphql;
GRANT TRIGGER ON view_workfrequency TO graphql;
GRANT TRUNCATE ON view_workfrequency TO graphql;
GRANT UPDATE ON view_workfrequency TO graphql;

-- Type: VIEW ; Name: view_workinstance_full; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workinstance_full AS
 SELECT wi.workinstanceid,
    wi.workinstancecustomerid,
    wi.workinstanceworktemplateid,
    wi.workinstancesiteid,
    wi.workinstancetypeid,
    wi.workinstancestatusid,
    wi.workinstancepreviousid,
    wi.workinstancecreateddate,
    wi.workinstancemodifieddate,
    wi.workinstancetargetstartdate,
    wi.workinstancestartdate,
    wi.workinstancecompleteddate,
    wi.workinstanceexpecteddurationinseconds,
    wi.workinstanceexternalsystemid,
    wi.workinstanceexternalid,
    wi.workinstancesoplink,
    wi.workinstancetrustreasoncodeid,
    wi.workinstanceoriginatorworkinstanceid,
    wi.id,
    wi.version,
    wi.workinstancetimezone,
    wi.workinstancecompleteddatetz,
    wi.workinstancestartdatetz,
    wi.workinstancetargetstartdatetz,
    wi.workinstancemodifiedby,
    wi.workinstancerefid,
    wi.workinstancerefuuid,
    wi.workinstanceproccessingstatusid,
    wi.workinstanceexpirationdate,
    wi.workinstancetexpirationdatetz,
    location.locationid AS workinstancelocationid,
    wt.worktemplatenameid AS workinstancenameid,
    workstatus.systagnameid AS workinstancestatusnameid,
    trustreason.systagnameid AS workinstancetrustreasoncodenameid,
    processingstatus.systagnameid AS workinstanceproccessingstatusnameid,
    worktype.systagnameid AS workinstancetypenameid,
    worker.workerinstanceid AS workinstanceworkerinstanceid,
    worker.workerinstancename AS workinstanceworkerinstancename
   FROM workinstance wi
     JOIN worktemplate wt ON wi.workinstanceworktemplateid = wt.worktemplateid
     JOIN systag worktype ON wi.workinstancetypeid = worktype.systagid
     JOIN workresult wrl ON wi.workinstanceworktemplateid = wrl.workresultworktemplateid AND wrl.workresulttypeid = 848 AND wrl.workresultentitytypeid = 852 AND wrl.workresultisprimary = true
     JOIN workresultinstance wril ON wi.workinstanceid = wril.workresultinstanceworkinstanceid AND wrl.workresultid = wril.workresultinstanceworkresultid AND wril.workresultinstancevalue IS NOT NULL AND wril.workresultinstancevalue <> ''::text
     JOIN location ON wril.workresultinstancevalue::bigint = location.locationid
     JOIN workresult wrw ON wi.workinstanceworktemplateid = wrw.workresultworktemplateid AND wrw.workresulttypeid = 848 AND wrw.workresultentitytypeid = 850 AND wrw.workresultisprimary = true
     LEFT JOIN workresultinstance wriw ON wi.workinstanceid = wriw.workresultinstanceworkinstanceid AND wrw.workresultid = wriw.workresultinstanceworkresultid AND wriw.workresultinstancevalue IS NOT NULL AND wriw.workresultinstancevalue <> ''::text
     LEFT JOIN view_workerinstance worker ON wriw.workresultinstancevalue::bigint = worker.workerinstanceid
     LEFT JOIN systag workstatus ON wi.workinstancestatusid = workstatus.systagid
     LEFT JOIN systag trustreason ON wi.workinstancetrustreasoncodeid = trustreason.systagid
     LEFT JOIN systag processingstatus ON wi.workinstanceproccessingstatusid = processingstatus.systagid;


GRANT INSERT ON view_workinstance_full TO authenticated;
GRANT SELECT ON view_workinstance_full TO authenticated;
GRANT UPDATE ON view_workinstance_full TO authenticated;
GRANT DELETE ON view_workinstance_full TO graphql;
GRANT INSERT ON view_workinstance_full TO graphql;
GRANT REFERENCES ON view_workinstance_full TO graphql;
GRANT SELECT ON view_workinstance_full TO graphql;
GRANT TRIGGER ON view_workinstance_full TO graphql;
GRANT TRUNCATE ON view_workinstance_full TO graphql;
GRANT UPDATE ON view_workinstance_full TO graphql;

-- Type: VIEW ; Name: view_workresource; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workresource AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    wr.workresourcecreateddate,
    wr.workresourcecustomerid,
    wr.workresourceenddate,
    wr.workresourceexternalid,
    wr.workresourceexternalsystemid,
    wr.workresourceid,
    wr.workresourcemodifiedby,
    wr.workresourcemodifieddate,
    wr.workresourceresourcecustomertypeid,
    custag.custagname AS workresourcecustomertypename,
    wr.workresourceresourcetasktypeid,
    wr.workresourceresourcetypeid,
    systag.systagname AS workresourcetypename,
    wr.workresourcestartdate,
    wr.workresourceworktemplateid
   FROM workresource wr
     JOIN customerrequestedlanguage crl ON wr.workresourcecustomerid = crl.customerrequestedlanguagecustomerid
     LEFT JOIN view_systag systag ON crl.customerrequestedlanguagelanguageid = systag.languagetranslationtypeid AND wr.workresourceresourcetypeid = systag.systagid
     LEFT JOIN view_custag custag ON crl.customerrequestedlanguagelanguageid = custag.languagetranslationtypeid AND wr.workresourcecustomerid = custag.custagcustomerid AND wr.workresourceresourcecustomertypeid = custag.custagid;


GRANT INSERT ON view_workresource TO authenticated;
GRANT SELECT ON view_workresource TO authenticated;
GRANT UPDATE ON view_workresource TO authenticated;
GRANT DELETE ON view_workresource TO graphql;
GRANT INSERT ON view_workresource TO graphql;
GRANT REFERENCES ON view_workresource TO graphql;
GRANT SELECT ON view_workresource TO graphql;
GRANT TRIGGER ON view_workresource TO graphql;
GRANT TRUNCATE ON view_workresource TO graphql;
GRANT UPDATE ON view_workresource TO graphql;

-- Type: VIEW ; Name: view_workresult; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workresult AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    wr.id,
    wr.workresultcreateddate,
    wr.workresultcustomerid,
    wr.workresultdefaultvalue,
    wr.workresultenddate,
    wr.workresultentitytypeid,
    entitytype.systagname AS workresultentitytypename,
    wr.workresultexternalid,
    wr.workresultexternalsystemid,
    wr.workresultforaudit,
    resultformat.custagtype AS workresultformat,
    wr.workresultformatid,
    wr.workresultfortask,
    wr.workresultid,
    wr.workresultiscalculated,
    wr.workresultiseditable,
    wr.workresultisprimary,
    wr.workresultisrequired,
    wr.workresultisvisible,
    wr.workresultlanguagemasterid,
    wr.workresultmodifiedby,
    wr.workresultmodifieddate,
    wr.workresultorder,
    wr.workresultsoplink,
    wr.workresultstartdate,
    wr.workresulttranslate,
    wr.workresulttypeid,
    resulttype.systagname AS workresulttypename,
    wr.workresultwidgetid,
    widget.custagtype AS workresultwidget,
    wr.workresultworktemplateid,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource) AS workresultname
   FROM workresult wr
     JOIN customerrequestedlanguage crl ON wr.workresultcustomerid = crl.customerrequestedlanguagecustomerid
     LEFT JOIN view_systag entitytype ON crl.customerrequestedlanguagelanguageid = entitytype.languagetranslationtypeid AND wr.workresultentitytypeid = entitytype.systagid
     LEFT JOIN view_systag resulttype ON crl.customerrequestedlanguagelanguageid = resulttype.languagetranslationtypeid AND wr.workresulttypeid = resulttype.systagid
     LEFT JOIN custag resultformat ON wr.workresultformatid = resultformat.custagid
     LEFT JOIN custag widget ON wr.workresultwidgetid = widget.custagid
     LEFT JOIN languagemaster lm ON wr.workresultlanguagemasterid = lm.languagemasterid
     LEFT JOIN languagetranslations lt ON crl.customerrequestedlanguagelanguageid = lt.languagetranslationtypeid AND wr.workresultlanguagemasterid = lt.languagetranslationmasterid AND wr.workresultcustomerid = lt.languagetranslationcustomerid;


GRANT INSERT ON view_workresult TO authenticated;
GRANT SELECT ON view_workresult TO authenticated;
GRANT UPDATE ON view_workresult TO authenticated;
GRANT DELETE ON view_workresult TO graphql;
GRANT INSERT ON view_workresult TO graphql;
GRANT REFERENCES ON view_workresult TO graphql;
GRANT SELECT ON view_workresult TO graphql;
GRANT TRIGGER ON view_workresult TO graphql;
GRANT TRUNCATE ON view_workresult TO graphql;
GRANT UPDATE ON view_workresult TO graphql;

-- Type: VIEW ; Name: view_activeworktemplate; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworktemplate AS
 SELECT languagetranslationtypeid,
    worktemplatedescription,
    worktemplatesoplink,
    id,
    worktemplateallowondemand,
    worktemplatecreateddate,
    worktemplatecustomerid,
    worktemplateenddate,
    worktemplateexpectedduration,
    worktemplateexpecteddurationtypeid,
    worktemplateexternalid,
    worktemplateexternalsystemid,
    worktemplateid,
    worktemplateisauditable,
    worktemplatelocationtypeid,
    worktemplatemodifiedby,
    worktemplatemodifieddate,
    worktemplatenameid,
    worktemplateorder,
    worktemplatescanid,
    worktemplatesiteid,
    worktemplatestartdate,
    worktemplateworkfrequencyid,
    worktemplatename
   FROM view_worktemplate
  WHERE worktemplateenddate IS NULL OR worktemplateenddate > now();


GRANT INSERT ON view_activeworktemplate TO authenticated;
GRANT SELECT ON view_activeworktemplate TO authenticated;
GRANT UPDATE ON view_activeworktemplate TO authenticated;
GRANT DELETE ON view_activeworktemplate TO graphql;
GRANT INSERT ON view_activeworktemplate TO graphql;
GRANT REFERENCES ON view_activeworktemplate TO graphql;
GRANT SELECT ON view_activeworktemplate TO graphql;
GRANT TRIGGER ON view_activeworktemplate TO graphql;
GRANT TRUNCATE ON view_activeworktemplate TO graphql;
GRANT UPDATE ON view_activeworktemplate TO graphql;

-- Type: VIEW ; Name: view_workinstance_full_v2; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workinstance_full_v2 AS
 SELECT wi.workinstanceid,
    wi.workinstancecustomerid,
    wi.workinstanceworktemplateid,
    wi.workinstancesiteid,
    wi.workinstancetypeid,
    wtt.worktemplatetypesystagid AS workinstancetemplatetypeid,
    wi.workinstancestatusid,
    wi.workinstancepreviousid,
    wi.workinstancecreateddate,
    wi.workinstancemodifieddate,
    wi.workinstancetargetstartdate,
    wi.workinstancestartdate,
    wi.workinstancecompleteddate,
    wi.workinstanceexpecteddurationinseconds,
    wi.workinstanceexternalsystemid,
    wi.workinstanceexternalid,
    wi.workinstancesoplink,
    wi.workinstancetrustreasoncodeid,
    wi.workinstanceoriginatorworkinstanceid,
    wi.id,
    wi.version,
    wi.workinstancetimezone,
    wi.workinstancecompleteddatetz,
    wi.workinstancestartdatetz,
    wi.workinstancetargetstartdatetz,
    wi.workinstancemodifiedby,
    wi.workinstancerefid,
    wi.workinstancerefuuid,
    wi.workinstanceproccessingstatusid,
    location.locationid AS workinstancelocationid,
    wt.worktemplatenameid AS workinstancenameid,
    workstatus.systagnameid AS workinstancestatusnameid,
    trustreason.systagnameid AS workinstancetrustreasoncodenameid,
    processingstatus.systagnameid AS workinstanceproccessingstatusnameid,
    worktype.systagnameid AS workinstancetypenameid,
    worker.workerinstanceid AS workinstanceworkerinstanceid,
    worker.workerinstancename AS workinstanceworkerinstancename
   FROM workinstance wi
     JOIN worktemplate wt ON wi.workinstanceworktemplateid = wt.worktemplateid
     LEFT JOIN worktemplatetype wtt ON wt.worktemplateid = wtt.worktemplatetypeworktemplateid
     JOIN systag worktype ON wi.workinstancetypeid = worktype.systagid
     JOIN workresult wrl ON wi.workinstanceworktemplateid = wrl.workresultworktemplateid AND wrl.workresulttypeid = 848 AND wrl.workresultentitytypeid = 852 AND wrl.workresultisprimary = true
     JOIN workresultinstance wril ON wi.workinstanceid = wril.workresultinstanceworkinstanceid AND wrl.workresultid = wril.workresultinstanceworkresultid AND wril.workresultinstancevalue IS NOT NULL AND wril.workresultinstancevalue <> ''::text
     JOIN location ON wril.workresultinstancevalue::bigint = location.locationid
     JOIN workresult wrw ON wi.workinstanceworktemplateid = wrw.workresultworktemplateid AND wrw.workresulttypeid = 848 AND wrw.workresultentitytypeid = 850 AND wrw.workresultisprimary = true
     LEFT JOIN workresultinstance wriw ON wi.workinstanceid = wriw.workresultinstanceworkinstanceid AND wrw.workresultid = wriw.workresultinstanceworkresultid AND wriw.workresultinstancevalue IS NOT NULL AND wriw.workresultinstancevalue <> ''::text
     LEFT JOIN view_workerinstance worker ON wriw.workresultinstancevalue::bigint = worker.workerinstanceid
     LEFT JOIN systag workstatus ON wi.workinstancestatusid = workstatus.systagid
     LEFT JOIN systag trustreason ON wi.workinstancetrustreasoncodeid = trustreason.systagid
     LEFT JOIN systag processingstatus ON wi.workinstanceproccessingstatusid = processingstatus.systagid;


GRANT INSERT ON view_workinstance_full_v2 TO authenticated;
GRANT SELECT ON view_workinstance_full_v2 TO authenticated;
GRANT UPDATE ON view_workinstance_full_v2 TO authenticated;
GRANT DELETE ON view_workinstance_full_v2 TO graphql;
GRANT INSERT ON view_workinstance_full_v2 TO graphql;
GRANT REFERENCES ON view_workinstance_full_v2 TO graphql;
GRANT SELECT ON view_workinstance_full_v2 TO graphql;
GRANT TRIGGER ON view_workinstance_full_v2 TO graphql;
GRANT TRUNCATE ON view_workinstance_full_v2 TO graphql;
GRANT UPDATE ON view_workinstance_full_v2 TO graphql;
ALTER TABLE registereddevice ALTER registereddeviceid SET DEFAULT nextval('registereddevice_registereddeviceid_seq'::regclass);
ALTER TABLE systag ADD CONSTRAINT systag_systagparentid_fkey
      FOREIGN KEY (systagparentid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_workfrequencytypeid_fkey
      FOREIGN KEY (workfrequencytypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstancemodifiedby_fkey
      FOREIGN KEY (workpictureinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatelocationtypeid_fkey
      FOREIGN KEY (worktemplatelocationtypeid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstancemimetypeid_fkey
      FOREIGN KEY (workpictureinstancemimetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE resource ADD CONSTRAINT resource_resourcecustomertypeid_fkey
      FOREIGN KEY (resourcecustomertypeid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE apikey ADD CONSTRAINT apikey_apikeymodifiedby_fkey
      FOREIGN KEY (apikeymodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplateworkfrequencyid_fkey
      FOREIGN KEY (worktemplateworkfrequencyid) REFERENCES workfrequency(workfrequencyid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worker ADD CONSTRAINT worker_workeridentitysystemid_fkey
      FOREIGN KEY (workeridentitysystemid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresource ADD CONSTRAINT workresource_workresourceworktemplateid_fkey
      FOREIGN KEY (workresourceworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE resource ADD CONSTRAINT resource_resourcetypeid_fkey
      FOREIGN KEY (resourcetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customerrequestedlanguage ADD CONSTRAINT customerrequestedlanguage_customerrequestedlanguagemodifie_fkey
      FOREIGN KEY (customerrequestedlanguagemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionworktemplateid_fkey
      FOREIGN KEY (workdescriptionworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresource ADD CONSTRAINT workresource_workresourceresourcecustomertypeid_fkey
      FOREIGN KEY (workresourceresourcecustomertypeid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE registereddevice ADD CONSTRAINT registereddevice_registereddevicemodifiedby_fkey
      FOREIGN KEY (registereddevicemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workfrequencyhistory ADD CONSTRAINT workfrequencyhistory_workfrequencyhistoryworkfrequencyid_fkey
      FOREIGN KEY (workfrequencyhistoryworkfrequencyid) REFERENCES workfrequency(workfrequencyid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worker ADD CONSTRAINT worker_workerlanguageid_fkey
      FOREIGN KEY (workerlanguageid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionworktemplateid_fkey
      FOREIGN KEY (workinstanceexceptionworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstancecustomerid_fkey
      FOREIGN KEY (workpictureinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE custag ADD CONSTRAINT custag_custagmodifiedby_fkey
      FOREIGN KEY (custagmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplateexpecteddurationtypeid_fkey
      FOREIGN KEY (worktemplateexpecteddurationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worker ADD CONSTRAINT worker_workeraddressid_fkey
      FOREIGN KEY (workeraddressid) REFERENCES address(addressid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE resource ADD CONSTRAINT resource_resourcecustomerid_fkey
      FOREIGN KEY (resourcecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE customerrequestedlanguage ADD CONSTRAINT systag_fkey
      FOREIGN KEY (customerrequestedlanguagelanguageid) REFERENCES systag(systagid);

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintcustomerid_fkey
      FOREIGN KEY (worktemplateconstraintcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionmodifiedby_fkey
      FOREIGN KEY (workdescriptionmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE address ADD CONSTRAINT address_addresscountryid_fkey
      FOREIGN KEY (addresscountryid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatecustomerid_fkey
      FOREIGN KEY (worktemplatecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE resource ADD CONSTRAINT resource_resourcemodifiedby_fkey
      FOREIGN KEY (resourcemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE address ADD CONSTRAINT address_addressstateid_fkey
      FOREIGN KEY (addressstateid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customer ADD CONSTRAINT customer_customermodifiedby_fkey
      FOREIGN KEY (customermodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionworkresultid_fkey
      FOREIGN KEY (workdescriptionworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT templateid_fkey
      FOREIGN KEY (locationtemplatedurationcalculationworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE address ADD CONSTRAINT address_addresstimezoneid_fkey
      FOREIGN KEY (addresstimezoneid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultformatid_fkey
      FOREIGN KEY (workresultformatid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worker ADD CONSTRAINT worker_workermodifiedby_fkey
      FOREIGN KEY (workermodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptioncustomerid_fkey
      FOREIGN KEY (workinstanceexceptioncustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "user" ADD CONSTRAINT addressid_fkey
      FOREIGN KEY (useraddressid) REFERENCES address(addressid);

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT locationtemplatedurationcalculation_locationtemplatedurati_fkey
      FOREIGN KEY (locationtemplatedurationcalculationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultwidgetid_fkey
      FOREIGN KEY (workresultwidgetid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE apikey ADD CONSTRAINT apikey_apikeycustomerid_fkey
      FOREIGN KEY (apikeycustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancemodifiedby_fkey
      FOREIGN KEY (workerinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypecustomerid_fkey
      FOREIGN KEY (worktemplatetypecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workicon ADD CONSTRAINT workicon_workiconworktemplateid_fkey
      FOREIGN KEY (workiconworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceworkerid_fkey
      FOREIGN KEY (workerinstanceworkerid) REFERENCES worker(workerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_workfrequencycustomerid_fkey
      FOREIGN KEY (workfrequencycustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT worktemplateid_fkey
      FOREIGN KEY (workertemplatedurationcalculationworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_invitationcodeinvitationtypeid_fkey
      FOREIGN KEY (invitationcodeinvitationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE custag ADD CONSTRAINT custag_custagcustomerid_fkey
      FOREIGN KEY (custagcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT templateid_fkey
      FOREIGN KEY (worktemplatedurationcalculationworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_invitationcodetransporttypeid_fkey
      FOREIGN KEY (invitationcodetransporttypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedfirstworkresultid_fkey
      FOREIGN KEY (workresultcalculatedfirstworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workfrequency ADD CONSTRAINT workfrequency_workfrequencymodifiedby_fkey
      FOREIGN KEY (workfrequencymodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresource ADD CONSTRAINT workresource_workresourcecustomerid_fkey
      FOREIGN KEY (workresourcecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT calculationtype_fkey
      FOREIGN KEY (locationtemplatedurationcalculationcalculationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE xlabel ADD CONSTRAINT labelnameid_fkey
      FOREIGN KEY (xlabelnameid) REFERENCES custag(custagid) NOT VALID;

ALTER TABLE customerrequestedlanguage ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (customerrequestedlanguagecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatemodifiedby_fkey
      FOREIGN KEY (worktemplatemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT worktype_fkey
      FOREIGN KEY (locationtemplatedurationcalculationworktypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedsecondworkresulti_fkey
      FOREIGN KEY (workresultcalculatedsecondworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "_customerToregistereddevice" ADD CONSTRAINT "_customerToregistereddevice_A_fkey"
      FOREIGN KEY ("A") REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workresource ADD CONSTRAINT workresource_workresourcemodifiedby_fkey
      FOREIGN KEY (workresourcemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE registereddevice ADD CONSTRAINT registereddevice_registereddeviceuserroleid_fkey
      FOREIGN KEY (registereddeviceuserroleid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultcustomerid_fkey
      FOREIGN KEY (workresultcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE systag ADD CONSTRAINT systag_systagmodifiedby_fkey
      FOREIGN KEY (systagmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceexternalsystemid_fkey
      FOREIGN KEY (workerinstanceexternalsystemid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE address ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (addresscustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultworktemplateid_fkey
      FOREIGN KEY (workresultworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE location ADD CONSTRAINT location_locationcategoryid_fkey
      FOREIGN KEY (locationcategoryid) REFERENCES custag(custagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customerbillingrecord ADD CONSTRAINT customerbillingrecord_customerbillingrecordcustomerid_fkey
      FOREIGN KEY (customerbillingrecordcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE invitationcode ADD CONSTRAINT invitationcode_invitationcodecustomerid_fkey
      FOREIGN KEY (invitationcodecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedworkresultid_fkey
      FOREIGN KEY (workresultcalculatedworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancelanguageid_fkey
      FOREIGN KEY (workerinstancelanguageid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (locationtemplatedurationcalculationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "user" ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (usercustomerid) REFERENCES customer(customerid);

ALTER TABLE location ADD CONSTRAINT location_locationcornerstoneid_fkey
      FOREIGN KEY (locationcornerstoneid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptioncustomerid_fkey
      FOREIGN KEY (workdescriptioncustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedcustomerid_fkey
      FOREIGN KEY (workresultcalculatedcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE worktemplateconstraint ADD CONSTRAINT worktemplateconstraint_worktemplateconstraintmodifiedby_fkey
      FOREIGN KEY (worktemplateconstraintmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultentitytypeid_fkey
      FOREIGN KEY (workresultentitytypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (workertemplatedurationcalculationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedmodifiedby_fkey
      FOREIGN KEY (workresultcalculatedmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workicon ADD CONSTRAINT workicon_workiconcustomerid_fkey
      FOREIGN KEY (workiconcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE location ADD CONSTRAINT location_locationparentid_fkey
      FOREIGN KEY (locationparentid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatetype ADD CONSTRAINT worktemplatetype_worktemplatetypemodifiedby_fkey
      FOREIGN KEY (worktemplatetypemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (worktemplatedurationcalculationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT workerinstanceid_fkey
      FOREIGN KEY (workertemplatedurationcalculationworkerid) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresulttypeid_fkey
      FOREIGN KEY (workresulttypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workweek ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (workweekcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT workertemplatedurationcalculation_workertemplatedurationca_fkey
      FOREIGN KEY (workertemplatedurationcalculationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE location ADD CONSTRAINT location_locationsiteid_fkey
      FOREIGN KEY (locationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workweekexception ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (workweekexceptioncustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workfrequencyhistory ADD CONSTRAINT workfrequencyhistory_workfrequencyhistorymodifiedby_fkey
      FOREIGN KEY (workfrequencyhistorymodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE xlabel ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (xlabelcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "user" ADD CONSTRAINT languageid_fkey
      FOREIGN KEY (userlanguageid) REFERENCES systag(systagid);

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultmodifiedby_fkey
      FOREIGN KEY (workresultmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE xtag ADD CONSTRAINT xtag_xtagcustomerid_fkey
      FOREIGN KEY (xtagcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionlanguagetypeid_fkey
      FOREIGN KEY (workdescriptionlanguagetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE customer ADD CONSTRAINT customer_customerlanguagetypeid_fkey
      FOREIGN KEY (customerlanguagetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionmodifiedby_fkey
      FOREIGN KEY (workinstanceexceptionmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT locationid_fkey
      FOREIGN KEY (locationtemplatedurationcalculationlocationid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE locationtemplatedurationcalculation ADD CONSTRAINT siteid_fkey
      FOREIGN KEY (locationtemplatedurationcalculationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionmimetypeid_fkey
      FOREIGN KEY (workdescriptionmimetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workerinstance ADD CONSTRAINT customerid_fkey
      FOREIGN KEY (workerinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE resource ADD CONSTRAINT resource_resourcesiteid_fkey
      FOREIGN KEY (resourcesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresource ADD CONSTRAINT workresource_workresourceresourcetypeid_fkey
      FOREIGN KEY (workresourceresourcetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedcalculationid_fkey
      FOREIGN KEY (workresultcalculatedcalculationid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT worktemplatedurationcalculation_worktemplatedurationcalcul_fkey
      FOREIGN KEY (worktemplatedurationcalculationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT calcualtiontypeid_fkey
      FOREIGN KEY (workertemplatedurationcalculationcalculationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT worktype_fkey
      FOREIGN KEY (workertemplatedurationcalculationworktypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE location ADD CONSTRAINT location_locationcustomerid_fkey
      FOREIGN KEY (locationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstanceuserroleid_fkey
      FOREIGN KEY (workerinstanceuserroleid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT calculationtype_fkey
      FOREIGN KEY (worktemplatedurationcalculationcalculationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE location ADD CONSTRAINT location_locationmodifiedby_fkey
      FOREIGN KEY (locationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT worktype_fkey
      FOREIGN KEY (worktemplatedurationcalculationworktypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workweek ADD CONSTRAINT timezoneid_fkey
      FOREIGN KEY (workweektimezoneid) REFERENCES systag(systagid) NOT VALID;

ALTER TABLE workweekexception ADD CONSTRAINT timezoneid_fkey
      FOREIGN KEY (workweekexceptiontimezoneid) REFERENCES systag(systagid);

ALTER TABLE xlabel ADD CONSTRAINT labletypeid_fkey
      FOREIGN KEY (xlabeltypeid) REFERENCES systag(systagid) NOT VALID;

ALTER TABLE workerinstance ADD CONSTRAINT workerinstance_workerinstancesiteid_fkey
      FOREIGN KEY (workerinstancesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE xtag ADD CONSTRAINT xtag_xsysparenttagid_fkey
      FOREIGN KEY (xsysparenttagid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE xtag ADD CONSTRAINT xtag_xsystagid_fkey
      FOREIGN KEY (xsystagid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultsiteid_fkey
      FOREIGN KEY (workresultsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatesiteid_fkey
      FOREIGN KEY (worktemplatesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultcalculated ADD CONSTRAINT workresultcalculated_workresultcalculatedsiteid_fkey
      FOREIGN KEY (workresultcalculatedsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workertemplatedurationcalculation ADD CONSTRAINT siteid_fkey
      FOREIGN KEY (workertemplatedurationcalculationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionlocationid_fkey
      FOREIGN KEY (workinstanceexceptionlocationid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstanceexception ADD CONSTRAINT workinstanceexception_workinstanceexceptionsiteid_fkey
      FOREIGN KEY (workinstanceexceptionsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplatedurationcalculation ADD CONSTRAINT siteid_fkey
      FOREIGN KEY (worktemplatedurationcalculationsiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workweek ADD CONSTRAINT locationid_fkey
      FOREIGN KEY (workweeklocationid) REFERENCES location(locationid) NOT VALID;

ALTER TABLE workweekexception ADD CONSTRAINT locationid_fkey
      FOREIGN KEY (workweekexceptionlocationid) REFERENCES location(locationid);

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT constraintid_fkey
      FOREIGN KEY (worktemplatenexttemplateviaworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatecustomeri_fkey
      FOREIGN KEY (worktemplatenexttemplatecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatemodifiedb_fkey
      FOREIGN KEY (worktemplatenexttemplatemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatenexttempl_fkey
      FOREIGN KEY (worktemplatenexttemplatenexttemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateprevioust_fkey
      FOREIGN KEY (worktemplatenexttemplateprevioustemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatesiteid_fkey
      FOREIGN KEY (worktemplatenexttemplatesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplatetypeid_fkey
      FOREIGN KEY (worktemplatenexttemplatetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateviastatus_fkey
      FOREIGN KEY (worktemplatenexttemplateviastatuschangeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplatenexttemplate ADD CONSTRAINT worktemplatenexttemplate_worktemplatenexttemplateviaworkre_fkey
      FOREIGN KEY (worktemplatenexttemplateviaworkresultcontstraintid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE entity.entityfieldinstance ADD CONSTRAINT efi_entityfieldinstancevaluelanguagemasteruuid_fk
      FOREIGN KEY (entityfieldinstancevaluelanguagemasteruuid) REFERENCES languagemaster(languagemasteruuid) NOT VALID;

ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastercustomerid_fkey
      FOREIGN KEY (languagemastercustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastercustomersiteid_fkey
      FOREIGN KEY (languagemastercustomersiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationcustomerid_fkey
      FOREIGN KEY (languagetranslationcustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastermodifiedby_fkey
      FOREIGN KEY (languagemastermodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationcustomersiteid_fkey
      FOREIGN KEY (languagetranslationcustomersiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE languagemaster ADD CONSTRAINT languagemaster_languagemastersourcelanguagetypeid_fkey
      FOREIGN KEY (languagemastersourcelanguagetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE entity.entityfield ADD CONSTRAINT entityfield_entityfieldlanguagemasteruuid_fkey
      FOREIGN KEY (entityfieldlanguagemasteruuid) REFERENCES languagemaster(languagemasteruuid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE entity.entitytemplate ADD CONSTRAINT entitytemplatenameuuid_languagmasteruuid_fk
      FOREIGN KEY (entitytemplatenameuuid) REFERENCES languagemaster(languagemasteruuid) NOT VALID;

ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationmodifiedby_fkey
      FOREIGN KEY (languagetranslationmodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationtypeid_fkey
      FOREIGN KEY (languagetranslationtypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancecustomerid_fkey
      FOREIGN KEY (workinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancemodifiedby_fkey
      FOREIGN KEY (workinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancenameid_fkey
      FOREIGN KEY (workinstancenameid) REFERENCES languagemaster(languagemasteruuid);

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstanceoriginatorworkinstanceid_fkey
      FOREIGN KEY (workinstanceoriginatorworkinstanceid) REFERENCES workinstance(workinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancepreviousid_fkey
      FOREIGN KEY (workinstancepreviousid) REFERENCES workinstance(workinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstanceproccessingstatusid_fkey
      FOREIGN KEY (workinstanceproccessingstatusid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancesiteid_fkey
      FOREIGN KEY (workinstancesiteid) REFERENCES location(locationid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancestatusid_fkey
      FOREIGN KEY (workinstancestatusid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancetrustreasoncodeid_fkey
      FOREIGN KEY (workinstancetrustreasoncodeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstancetypeid_fkey
      FOREIGN KEY (workinstancetypeid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workinstance ADD CONSTRAINT workinstance_workinstanceworktemplateid_fkey
      FOREIGN KEY (workinstanceworktemplateid) REFERENCES worktemplate(worktemplateid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstanceworkinstanceid_fkey
      FOREIGN KEY (workpictureinstanceworkinstanceid) REFERENCES workinstance(workinstanceid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancecustomerid_fkey
      FOREIGN KEY (workresultinstancecustomerid) REFERENCES customer(customerid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancemodifiedby_fkey
      FOREIGN KEY (workresultinstancemodifiedby) REFERENCES workerinstance(workerinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancestatusid_fkey
      FOREIGN KEY (workresultinstancestatusid) REFERENCES systag(systagid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstanceworkinstanceid_fkey
      FOREIGN KEY (workresultinstanceworkinstanceid) REFERENCES workinstance(workinstanceid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstanceworkresultid_fkey
      FOREIGN KEY (workresultinstanceworkresultid) REFERENCES workresult(workresultid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workpictureinstance ADD CONSTRAINT workpictureinstance_workpictureinstanceworkresultinstancei_fkey
      FOREIGN KEY (workpictureinstanceworkresultinstanceid) REFERENCES workresultinstance(workresultinstanceid) ON UPDATE CASCADE ON DELETE SET NULL;


-- Type: FUNCTION ; Name: api.delete_location(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_location(owner uuid, id uuid)
 RETURNS SETOF api.location
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_location_delete(
	      create_locationownerentityuuid := owner,
	      create_locationentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.location t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_location(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_location(uuid,uuid) TO authenticated;

-- Type: FUNCTION ; Name: api.delete_reason_code(uuid,uuid,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_reason_code(owner uuid, id uuid, work_template_constraint text, work_template text)
 RETURNS SETOF api.reason_code
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

-- NEED TO ADD MORE CONDITIONS.  
-- DO WE ALLOW THE CONSTRAINT TO BE DELETED OR JUST THE CUSTAG TO BE DEACTIVATED.
-- VERSION BELOW JUST DEACTIVATES THE CUSTAG, BUT THAT IS FOR ALL TEMPLATES.

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_custag_delete(
	      create_custagownerentityuuid := owner,
	      create_custagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
end if;

  return query
    select *
    from api.reason_code t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO authenticated;

-- Type: VIEW ; Name: view_activeresource; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeresource AS
 SELECT languagetranslationtypeid,
    resourcecreateddate,
    resourcecustomerid,
    resourcecustomertypeid,
    resourcecustomertypename,
    resourceenddate,
    resourceexternalid,
    resourceexternalsystemid,
    resourceid,
    resourcelookupname,
    resourcemodifiedby,
    resourcemodifieddate,
    resourcenameid,
    resourceorder,
    resourcescanid,
    resourcesiteid,
    resourcestartdate,
    resourcetypeid,
    resourcetypename,
    resourceuuid,
    resourcefullname
   FROM view_resource
  WHERE resourceenddate IS NULL OR resourceenddate > now();


GRANT INSERT ON view_activeresource TO authenticated;
GRANT SELECT ON view_activeresource TO authenticated;
GRANT UPDATE ON view_activeresource TO authenticated;
GRANT DELETE ON view_activeresource TO graphql;
GRANT INSERT ON view_activeresource TO graphql;
GRANT REFERENCES ON view_activeresource TO graphql;
GRANT SELECT ON view_activeresource TO graphql;
GRANT TRIGGER ON view_activeresource TO graphql;
GRANT TRUNCATE ON view_activeresource TO graphql;
GRANT UPDATE ON view_activeresource TO graphql;

-- Type: VIEW ; Name: view_activeworkfrequency; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkfrequency AS
 SELECT languagetranslationtypeid,
    workfrequencycreateddate,
    workfrequencycustomerid,
    workfrequencyenddate,
    workfrequencyexternalid,
    workfrequencyexternalsystemid,
    workfrequencyid,
    workfrequencymodifiedby,
    workfrequencymodifieddate,
    workfrequencystartdate,
    workfrequencytypeid,
    workfrequencytypename,
    workfrequencyvalue,
    workfrequencyworktemplateid
   FROM view_workfrequency
  WHERE workfrequencyenddate IS NULL OR workfrequencyenddate > now();


GRANT INSERT ON view_activeworkfrequency TO authenticated;
GRANT SELECT ON view_activeworkfrequency TO authenticated;
GRANT UPDATE ON view_activeworkfrequency TO authenticated;
GRANT DELETE ON view_activeworkfrequency TO graphql;
GRANT INSERT ON view_activeworkfrequency TO graphql;
GRANT REFERENCES ON view_activeworkfrequency TO graphql;
GRANT SELECT ON view_activeworkfrequency TO graphql;
GRANT TRIGGER ON view_activeworkfrequency TO graphql;
GRANT TRUNCATE ON view_activeworkfrequency TO graphql;
GRANT UPDATE ON view_activeworkfrequency TO graphql;

-- Type: VIEW ; Name: view_workinstance; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workinstance AS
 SELECT crl.customerrequestedlanguagelanguageid AS languagetranslationtypeid,
    wi.id,
    wi.workinstancecompleteddate,
    wi.workinstancecreateddate,
    wi.workinstancecustomerid,
    wi.workinstanceexpecteddurationinseconds,
    wi.workinstanceexternalid,
    wi.workinstanceexternalsystemid,
    wi.workinstanceid,
    wi.workinstancelocationid,
    wi.workinstancemodifiedby,
    wi.workinstancemodifieddate,
    wi.workinstancenameid,
    wi.workinstanceoriginatorworkinstanceid,
    pwi.workinstancecompleteddate AS workinstancepreviousdate,
    wi.workinstancepreviousid,
    pwi.workinstanceworkerinstanceid AS workinstancepreviousworkerinstanceid,
    pwi.workinstanceworkerinstancename AS workinstancepreviousworkerinstancename,
    wi.workinstanceproccessingstatusid,
    wi.workinstancesiteid,
    wi.workinstancesoplink,
    wi.workinstancestartdate,
    wi.workinstancestatusid,
    wi.workinstancetargetstartdate,
    wi.workinstancetrustreasoncodeid,
    wi.workinstancetypeid,
    wi.workinstanceworkerinstanceid,
    wi.workinstanceworktemplateid,
    wi.workinstanceworkerinstancename,
    wi.version,
    wi.workinstancecompleteddatetz,
    wi.workinstancestartdatetz,
    wi.workinstancetargetstartdatetz,
    wi.workinstancetimezone,
    COALESCE(t_name.languagetranslationvalue, m_name.languagemastersource) AS workinstancename,
    COALESCE(t_worktype.languagetranslationvalue, m_worktype.languagemastersource) AS workinstancetypename,
    COALESCE(t_workstatus.languagetranslationvalue, m_workstatus.languagemastersource) AS workinstancestatusname,
    COALESCE(t_trustreason.languagetranslationvalue, m_trustreason.languagemastersource) AS workinstancetrustreasoncodename,
    COALESCE(t_processingstatus.languagetranslationvalue, m_processingstatus.languagemastersource) AS workinstanceprocessingstatusname
   FROM view_workinstance_full wi
     JOIN customerrequestedlanguage crl ON wi.workinstancecustomerid = crl.customerrequestedlanguagecustomerid
     JOIN languagemaster m_name ON wi.workinstancenameid = m_name.languagemasterid
     LEFT JOIN languagetranslations t_name ON m_name.languagemasterid = t_name.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = t_name.languagetranslationtypeid
     JOIN languagemaster m_worktype ON wi.workinstancetypenameid = m_worktype.languagemasterid
     LEFT JOIN languagetranslations t_worktype ON m_worktype.languagemasterid = t_worktype.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = t_worktype.languagetranslationtypeid
     LEFT JOIN languagemaster m_workstatus ON wi.workinstancestatusnameid = m_workstatus.languagemasterid
     LEFT JOIN languagetranslations t_workstatus ON m_workstatus.languagemasterid = t_workstatus.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = t_workstatus.languagetranslationtypeid
     LEFT JOIN languagemaster m_trustreason ON wi.workinstancetrustreasoncodenameid = m_trustreason.languagemasterid
     LEFT JOIN languagetranslations t_trustreason ON m_trustreason.languagemasterid = t_trustreason.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = t_trustreason.languagetranslationtypeid
     LEFT JOIN languagemaster m_processingstatus ON wi.workinstanceproccessingstatusnameid = m_processingstatus.languagemasterid
     LEFT JOIN languagetranslations t_processingstatus ON m_processingstatus.languagemasterid = t_processingstatus.languagetranslationmasterid AND crl.customerrequestedlanguagelanguageid = t_processingstatus.languagetranslationtypeid
     LEFT JOIN view_workinstance_full pwi ON wi.workinstancepreviousid = pwi.workinstanceid;


GRANT INSERT ON view_workinstance TO authenticated;
GRANT SELECT ON view_workinstance TO authenticated;
GRANT UPDATE ON view_workinstance TO authenticated;
GRANT DELETE ON view_workinstance TO graphql;
GRANT INSERT ON view_workinstance TO graphql;
GRANT REFERENCES ON view_workinstance TO graphql;
GRANT SELECT ON view_workinstance TO graphql;
GRANT TRIGGER ON view_workinstance TO graphql;
GRANT TRUNCATE ON view_workinstance TO graphql;
GRANT UPDATE ON view_workinstance TO graphql;

-- Type: VIEW ; Name: view_activeworkresource; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkresource AS
 SELECT v.languagetranslationtypeid,
    v.workresourcecreateddate,
    v.workresourcecustomerid,
    v.workresourceenddate,
    v.workresourceexternalid,
    v.workresourceexternalsystemid,
    v.workresourceid,
    v.workresourcemodifiedby,
    v.workresourcemodifieddate,
    v.workresourceresourcecustomertypeid,
    v.workresourcecustomertypename,
    v.workresourceresourcetasktypeid,
    v.workresourceresourcetypeid,
    v.workresourcetypename,
    v.workresourcestartdate,
    v.workresourceworktemplateid
   FROM view_workresource v
     JOIN worktemplate t ON v.workresourceworktemplateid = t.worktemplateid AND (t.worktemplateenddate IS NULL OR t.worktemplateenddate > now())
  WHERE v.workresourceenddate IS NULL OR v.workresourceenddate > now();


GRANT INSERT ON view_activeworkresource TO authenticated;
GRANT SELECT ON view_activeworkresource TO authenticated;
GRANT UPDATE ON view_activeworkresource TO authenticated;
GRANT DELETE ON view_activeworkresource TO graphql;
GRANT INSERT ON view_activeworkresource TO graphql;
GRANT REFERENCES ON view_activeworkresource TO graphql;
GRANT SELECT ON view_activeworkresource TO graphql;
GRANT TRIGGER ON view_activeworkresource TO graphql;
GRANT TRUNCATE ON view_activeworkresource TO graphql;
GRANT UPDATE ON view_activeworkresource TO graphql;

-- Type: VIEW ; Name: view_activeworkresult; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkresult AS
 SELECT v.languagetranslationtypeid,
    v.id,
    v.workresultcreateddate,
    v.workresultcustomerid,
    v.workresultdefaultvalue,
    v.workresultenddate,
    v.workresultentitytypeid,
    v.workresultentitytypename,
    v.workresultexternalid,
    v.workresultexternalsystemid,
    v.workresultforaudit,
    v.workresultformat,
    v.workresultformatid,
    v.workresultfortask,
    v.workresultid,
    v.workresultiscalculated,
    v.workresultiseditable,
    v.workresultisprimary,
    v.workresultisrequired,
    v.workresultisvisible,
    v.workresultlanguagemasterid,
    v.workresultmodifiedby,
    v.workresultmodifieddate,
    v.workresultorder,
    v.workresultsoplink,
    v.workresultstartdate,
    v.workresulttranslate,
    v.workresulttypeid,
    v.workresulttypename,
    v.workresultwidgetid,
    v.workresultwidget,
    v.workresultworktemplateid,
    v.workresultname
   FROM view_workresult v
     JOIN worktemplate t ON v.workresultworktemplateid = t.worktemplateid AND (t.worktemplateenddate IS NULL OR t.worktemplateenddate > now())
  WHERE v.workresultenddate IS NULL OR v.workresultenddate > now();


GRANT INSERT ON view_activeworkresult TO authenticated;
GRANT SELECT ON view_activeworkresult TO authenticated;
GRANT UPDATE ON view_activeworkresult TO authenticated;
GRANT DELETE ON view_activeworkresult TO graphql;
GRANT INSERT ON view_activeworkresult TO graphql;
GRANT REFERENCES ON view_activeworkresult TO graphql;
GRANT SELECT ON view_activeworkresult TO graphql;
GRANT TRIGGER ON view_activeworkresult TO graphql;
GRANT TRUNCATE ON view_activeworkresult TO graphql;
GRANT UPDATE ON view_activeworkresult TO graphql;

-- Type: VIEW ; Name: view_workresultinstance; Owner: tendreladmin

CREATE OR REPLACE VIEW view_workresultinstance AS
 SELECT wr.languagetranslationtypeid,
    wri.workresultinstancecompleteddate,
    wri.workresultinstancecreateddate,
    wri.workresultinstancecustomerid,
    wr.workresultentitytypeid AS workresultinstanceentitytypeid,
    wr.workresultentitytypename AS workresultinstanceentitytypename,
    wr.workresultformatid AS workresultinstanceformatid,
    wr.workresultformat AS workresultinstanceformat,
    wri.workresultinstanceexternalid,
    wri.workresultinstanceexternalsystemid,
    wri.workresultinstanceid,
    wr.workresultiscalculated AS workresultinstanceiscalculated,
    wr.workresultiseditable AS workresultinstanceiseditable,
    wr.workresultisprimary AS workresultinstanceisprimary,
    wr.workresultisrequired AS workresultinstanceisrequired,
    wr.workresultisvisible AS workresultinstanceisvisible,
    wri.workresultinstancemodifiedby,
    wri.workresultinstancemodifieddate,
    wr.workresultname AS workresultinstancename,
    wri.workresultinstancestartdate,
    wr.workresulttypeid AS workresultinstancetypeid,
    wr.workresulttypename AS workresultinstancetypename,
    wri.workresultinstancevaluelanguagemasterid,
    wri.workresultinstancevaluelanguagetypeid,
    wr.workresultwidgetid AS workresultinstancewidgetid,
    wr.workresultwidget AS workresultinstancewidget,
    wri.workresultinstanceworkinstanceid,
    wri.workresultinstanceworkresultid,
    wr.workresultorder AS workresultinstanceworkresultorder,
    wri.workresultinstancetimezone,
    wri.workresultinstancecreateddatetz,
    wri.workresultinstancecompleteddatetz,
    wri.workresultinstancestartdatetz,
    COALESCE(lt.languagetranslationvalue, lm.languagemastersource, wri.workresultinstancevalue) AS workresultinstancevalue
   FROM workresultinstance wri
     JOIN view_workresult wr ON wri.workresultinstanceworkresultid = wr.workresultid
     LEFT JOIN languagetranslations lt ON wri.workresultinstancevaluelanguagemasterid = lt.languagetranslationmasterid AND wr.languagetranslationtypeid = lt.languagetranslationtypeid
     LEFT JOIN languagemaster lm ON wri.workresultinstancevaluelanguagemasterid = lm.languagemasterid;


GRANT INSERT ON view_workresultinstance TO authenticated;
GRANT SELECT ON view_workresultinstance TO authenticated;
GRANT UPDATE ON view_workresultinstance TO authenticated;
GRANT DELETE ON view_workresultinstance TO graphql;
GRANT INSERT ON view_workresultinstance TO graphql;
GRANT REFERENCES ON view_workresultinstance TO graphql;
GRANT SELECT ON view_workresultinstance TO graphql;
GRANT TRIGGER ON view_workresultinstance TO graphql;
GRANT TRUNCATE ON view_workresultinstance TO graphql;
GRANT UPDATE ON view_workresultinstance TO graphql;

-- Type: VIEW ; Name: view_internalcalcformulacheck; Owner: tendreladmin

CREATE OR REPLACE VIEW view_internalcalcformulacheck AS
 SELECT calc.workresultcalculatedid AS calculatedid,
    calc.workresultcalculatedcustomerid AS customerid,
    wt.worktemplatename AS template,
    cwri.workresultname AS resultname,
    '='::text AS equals,
    fwri.workresultname AS firstresultname,
    calc.workresultcalculatedcalcualtionidcalcualtionname AS calcname,
    swri.workresultname AS secondresultname,
    calc.workresultcalculatedworkresultid AS calculatedresultid,
    wt.worktemplateid AS templateid,
    calc.workresultcalculatedfirstworkresultid AS firstresultid,
    calc.workresultcalculatedsecondworkresultid AS secondresultid
   FROM workresultcalculated calc
     JOIN view_workresult cwri ON calc.workresultcalculatedworkresultid = cwri.workresultid AND cwri.languagetranslationtypeid = 20
     JOIN view_worktemplate wt ON cwri.workresultworktemplateid = wt.worktemplateid AND wt.languagetranslationtypeid = 20
     JOIN view_workresult fwri ON calc.workresultcalculatedfirstworkresultid = fwri.workresultid AND fwri.languagetranslationtypeid = 20
     JOIN view_workresult swri ON calc.workresultcalculatedsecondworkresultid = swri.workresultid AND swri.languagetranslationtypeid = 20
  ORDER BY calc.workresultcalculatedcustomerid, cwri.workresultname;


GRANT INSERT ON view_internalcalcformulacheck TO authenticated;
GRANT SELECT ON view_internalcalcformulacheck TO authenticated;
GRANT UPDATE ON view_internalcalcformulacheck TO authenticated;
GRANT DELETE ON view_internalcalcformulacheck TO graphql;
GRANT INSERT ON view_internalcalcformulacheck TO graphql;
GRANT REFERENCES ON view_internalcalcformulacheck TO graphql;
GRANT SELECT ON view_internalcalcformulacheck TO graphql;
GRANT TRIGGER ON view_internalcalcformulacheck TO graphql;
GRANT TRUNCATE ON view_internalcalcformulacheck TO graphql;
GRANT UPDATE ON view_internalcalcformulacheck TO graphql;
ALTER TABLE apikey ADD CONSTRAINT "apikey_registereddeviceRegistereddeviceid_fkey"
      FOREIGN KEY ("registereddeviceRegistereddeviceid") REFERENCES registereddevice(registereddeviceid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE "_customerToregistereddevice" ADD CONSTRAINT "_customerToregistereddevice_B_fkey"
      FOREIGN KEY ("B") REFERENCES registereddevice(registereddeviceid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE custag ADD CONSTRAINT custag_custagabbreviationid_fkey
      FOREIGN KEY (custagabbreviationid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE custag ADD CONSTRAINT custag_custagnameid_fkey
      FOREIGN KEY (custagnameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE customer ADD CONSTRAINT customer_customernamelanguagemasterid_fkey
      FOREIGN KEY (customernamelanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE resource ADD CONSTRAINT resource_resourcenameid_fkey
      FOREIGN KEY (resourcenameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE location ADD CONSTRAINT location_locationnameid_fkey
      FOREIGN KEY (locationnameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workdescription ADD CONSTRAINT workdescription_workdescriptionlanguagemasterid_fkey
      FOREIGN KEY (workdescriptionlanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE languagetranslations ADD CONSTRAINT languagetranslations_languagetranslationmasterid_fkey
      FOREIGN KEY (languagetranslationmasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE systag ADD CONSTRAINT systag_systagabbreviationid_fkey
      FOREIGN KEY (systagabbreviationid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE systag ADD CONSTRAINT systag_systagnameid_fkey
      FOREIGN KEY (systagnameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresult ADD CONSTRAINT workresult_workresultlanguagemasterid_fkey
      FOREIGN KEY (workresultlanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatedescriptionid_fkey
      FOREIGN KEY (worktemplatedescriptionid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE worktemplate ADD CONSTRAINT worktemplate_worktemplatenameid_fkey
      FOREIGN KEY (worktemplatenameid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE workresultinstance ADD CONSTRAINT workresultinstance_workresultinstancevaluelanguagemasterid_fkey
      FOREIGN KEY (workresultinstancevaluelanguagemasterid) REFERENCES languagemaster(languagemasterid) ON UPDATE CASCADE ON DELETE SET NULL;


-- Type: VIEW ; Name: view_activeworkinstance; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkinstance AS
 SELECT v.languagetranslationtypeid,
    v.id,
    v.workinstancecompleteddate,
    v.workinstancecreateddate,
    v.workinstancecustomerid,
    v.workinstanceexpecteddurationinseconds,
    v.workinstanceexternalid,
    v.workinstanceexternalsystemid,
    v.workinstanceid,
    v.workinstancelocationid,
    v.workinstancemodifiedby,
    v.workinstancemodifieddate,
    v.workinstancenameid,
    v.workinstanceoriginatorworkinstanceid,
    v.workinstancepreviousdate,
    v.workinstancepreviousid,
    v.workinstancepreviousworkerinstanceid,
    v.workinstancepreviousworkerinstancename,
    v.workinstanceproccessingstatusid,
    v.workinstancesiteid,
    v.workinstancesoplink,
    v.workinstancestartdate,
    v.workinstancestatusid,
    v.workinstancetargetstartdate,
    v.workinstancetrustreasoncodeid,
    v.workinstancetypeid,
    v.workinstanceworkerinstanceid,
    v.workinstanceworktemplateid,
    v.workinstanceworkerinstancename,
    v.version,
    v.workinstancecompleteddatetz,
    v.workinstancestartdatetz,
    v.workinstancetargetstartdatetz,
    v.workinstancetimezone,
    v.workinstancename,
    v.workinstancetypename,
    v.workinstancestatusname,
    v.workinstancetrustreasoncodename,
    v.workinstanceprocessingstatusname
   FROM view_workinstance v
     JOIN worktemplate t ON v.workinstanceworktemplateid = t.worktemplateid AND (t.worktemplateenddate IS NULL OR t.worktemplateenddate > now());


GRANT INSERT ON view_activeworkinstance TO authenticated;
GRANT SELECT ON view_activeworkinstance TO authenticated;
GRANT UPDATE ON view_activeworkinstance TO authenticated;
GRANT DELETE ON view_activeworkinstance TO graphql;
GRANT INSERT ON view_activeworkinstance TO graphql;
GRANT REFERENCES ON view_activeworkinstance TO graphql;
GRANT SELECT ON view_activeworkinstance TO graphql;
GRANT TRIGGER ON view_activeworkinstance TO graphql;
GRANT TRUNCATE ON view_activeworkinstance TO graphql;
GRANT UPDATE ON view_activeworkinstance TO graphql;

-- Type: VIEW ; Name: view_activeworkresultinstance; Owner: tendreladmin

CREATE OR REPLACE VIEW view_activeworkresultinstance AS
 SELECT v.languagetranslationtypeid,
    v.workresultinstancecompleteddate,
    v.workresultinstancecreateddate,
    v.workresultinstancecustomerid,
    v.workresultinstanceentitytypeid,
    v.workresultinstanceentitytypename,
    v.workresultinstanceformatid,
    v.workresultinstanceformat,
    v.workresultinstanceexternalid,
    v.workresultinstanceexternalsystemid,
    v.workresultinstanceid,
    v.workresultinstanceiscalculated,
    v.workresultinstanceiseditable,
    v.workresultinstanceisprimary,
    v.workresultinstanceisrequired,
    v.workresultinstanceisvisible,
    v.workresultinstancemodifiedby,
    v.workresultinstancemodifieddate,
    v.workresultinstancename,
    v.workresultinstancestartdate,
    v.workresultinstancetypeid,
    v.workresultinstancetypename,
    v.workresultinstancevaluelanguagemasterid,
    v.workresultinstancevaluelanguagetypeid,
    v.workresultinstancewidgetid,
    v.workresultinstancewidget,
    v.workresultinstanceworkinstanceid,
    v.workresultinstanceworkresultid,
    v.workresultinstanceworkresultorder,
    v.workresultinstancetimezone,
    v.workresultinstancecreateddatetz,
    v.workresultinstancecompleteddatetz,
    v.workresultinstancestartdatetz,
    v.workresultinstancevalue
   FROM view_workresultinstance v
     JOIN workresult t0 ON v.workresultinstanceworkresultid = t0.workresultid AND (t0.workresultenddate IS NULL OR t0.workresultenddate > now())
     JOIN worktemplate t1 ON t0.workresultworktemplateid = t1.worktemplateid AND (t1.worktemplateenddate IS NULL OR t1.worktemplateenddate > now());


GRANT INSERT ON view_activeworkresultinstance TO authenticated;
GRANT SELECT ON view_activeworkresultinstance TO authenticated;
GRANT UPDATE ON view_activeworkresultinstance TO authenticated;
GRANT DELETE ON view_activeworkresultinstance TO graphql;
GRANT INSERT ON view_activeworkresultinstance TO graphql;
GRANT REFERENCES ON view_activeworkresultinstance TO graphql;
GRANT SELECT ON view_activeworkresultinstance TO graphql;
GRANT TRIGGER ON view_activeworkresultinstance TO graphql;
GRANT TRUNCATE ON view_activeworkresultinstance TO graphql;
GRANT UPDATE ON view_activeworkresultinstance TO graphql;

END;
