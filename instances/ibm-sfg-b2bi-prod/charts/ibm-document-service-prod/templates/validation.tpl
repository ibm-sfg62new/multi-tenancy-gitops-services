# (C) Copyright 2021 Syncsort Incorporated. All rights reserved.

{{- /*
A function to validate if passed parameter is a valid integer
*/ -}}
{{- define "documentService.integerValidation" -}}
{{- $type := kindOf . -}}
{{- if or (eq $type "float64") (eq $type "int") -}}
    {{- $isIntegerPositive := include "documentService.isIntegerPositive" . -}}
    {{- if eq $isIntegerPositive "true" -}}
    	true
    {{- else -}}
    	false
    {{- end -}}	
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to validate if passed integer is non negative
*/}}
{{- define "documentService.isIntegerPositive" -}}
{{- $inputInt := int64 . -}}
{{- if gt $inputInt -1 -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to validate if passed parameter is a valid string
*/}}
{{- define "documentService.stringValidation" -}}
{{- $type := kindOf . -}}
{{- if or (eq $type "string") (eq $type "String") -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check for mandatory arguments
*/}}
{{- define "documentService.mandatoryArgumentsCheck" -}}
{{- if . -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check for port range
*/}}
{{- define "documentService.portRangeValidation" -}}
{{- $portNo := int64 . -}}
{{- if and (gt $portNo 0) (lt $portNo 65536) -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check if port is valid
*/}}
{{- define "documentService.isPortValid" -}}
{{- $result := include "documentService.integerValidation" . -}}
{{- if eq $result "true" -}}
	{{- $isPortValid := include "documentService.portRangeValidation" . -}}
	{{- if eq $isPortValid "true" -}}
	true
	{{- else -}}
	false
	{{- end -}}
{{- else -}}
	false
{{- end -}}
{{- end -}}

{{/*
A function to check if port range is valid
*/}}
{{- define "documentService.isPortRangeValid" -}}
{{- $result := false -}}
{{- $portRangeNumbers := split "-" . -}}
{{- $isPortRangeStartValid := include "documentService.isPortValid" ($portRangeNumbers._0|int) -}}
{{- if eq $isPortRangeStartValid "true" -}}
	{{- $isPortRangeEndValid := include "documentService.isPortValid" ($portRangeNumbers._1|int) -}}
	{{- if eq $isPortRangeEndValid "true" -}}
	{{- $isPortRangeOrderValid := ge ($portRangeNumbers._1|int) ($portRangeNumbers._0|int) -}}
	{{- if eq $isPortRangeOrderValid true -}}
	{{- $result = true -}}
	{{- end -}}
	{{- end -}}
{{- end -}}
{{- if eq $result true -}}
  true
{{- else -}}
  false
{{- end -}}
{{- end -}}

{{/*
A function to check if name is valid
*/}}
{{- define "documentService.isNameValid" -}}
{{- $result := regexMatch "[a-z0-9]([-a-z0-9]*[a-z0-9])?" . -}}
{{- if eq $result true -}}
  true
{{- else -}}
  false
{{- end -}}
{{- end -}}


{{/*
A function to check for validity of service ports
*/}}
{{- define "documentService.servicePortCheck" -}}
{{- $result := include "documentService.isPortValid" .port -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for port in service" -}}
{{- end -}}
{{- $result := include "documentService.isPortValid" .targetPort -}}
{{- if eq $result "false" -}}
{{- $nameCheck := include "documentService.isNameValid" .targetPort -}}
{{- if eq $nameCheck "false" -}}
{{- fail "Provide a valid value for targetPort in service" -}}
{{- end -}}
{{- end -}}

{{- $nodePortValue := .nodePort -}}
{{- if $nodePortValue -}}
{{- $result := include "documentService.isPortValid" .nodePort -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for nodePort in service" -}}
{{- end -}}
{{- end -}}

{{- $result := include "documentService.isNameValid" .name -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for name in service" -}}
{{- end -}}

{{- $result := .protocol -}}
{{- if $result -}}
{{- if not (or (eq $result "TCP") (eq $result "UDP") (eq $result "HTTP") (eq $result "SCTP") (eq $result "PROXY")) -}}
{{- fail "Provide a valid value for protocol in service. Valid values are TCP, UDP, HTTP, SCTP or PROXY" -}}
{{- end -}}
{{- end -}}

{{- end -}}

{{/*
A function to check for validity of service ports
*/}}
{{- define "documentService.servicePortRangeCheck" -}}

{{- $result := include "documentService.isPortRangeValid" .portRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for port range in service" -}}
{{- end -}}

{{- $result := include "documentService.isPortRangeValid" .targetPortRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for target port range in service" -}}
{{- end -}}

{{- if .nodePortRange -}}
{{- $result := include "documentService.isPortRangeValid" .nodePortRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for node port range in service" -}}
{{- end -}}
{{- end -}}

{{- $result := include "documentService.isNameValid" .name -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for name in service" -}}
{{- end -}}

{{- $result := .protocol -}}
{{- if $result -}}
{{- if not (or (eq $result "TCP") (eq $result "UDP") (eq $result "HTTP") (eq $result "SCTP") (eq $result "PROXY")) -}}
{{- fail "Provide a valid value for protocol in service. Valid values are TCP, UDP, HTTP, SCTP or PROXY" -}}
{{- end -}}
{{- end -}}

{{- end -}}

{{/*
A function to validate an email address
*/}}
{{- define "documentService.emailValidator" -}}
{{- $emailRegex := "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$" -}}
{{- $isValid := regexMatch $emailRegex . -}}
{{- if eq $isValid true -}}
	true
{{- else -}}
	false	
{{- end -}}
{{- end -}}

{{/*
A function to validate the user or group name and ID
*/}}
{{- define "documentService.userOrGroupNameIDValidator" -}}
{{- $isInteger := include "documentService.integerValidation" . -}}
{{- if eq $isInteger "true" -}}
	true
{{- else -}}
	{{- $userOrGroupNameRegex := "^[a-z][-a-z0-9]*$" -}}
	{{- $isValid := regexMatch $userOrGroupNameRegex . -}}
	{{- if eq $isValid true -}}
		true
	{{- else -}}
		false
	{{- end -}}				
{{- end -}}
{{- end -}}

{{/*
A function to validate arch
*/}}
{{- define "documentService.archValidator" -}}
{{- $archList := list "0 - Do not use" "1 - Least preferred" "2 - No Preference" "3 - Most preferred" -}}
{{- $isValid := has . $archList -}}
{{- if eq $isValid true -}}
	true
{{- else -}}
	false	
{{- end -}}
{{- end -}}

{{/*
Main function to test the input validations
*/}}

{{- define "documentService.validateInput" -}}

{{- $isValid := .Values.license }}
{{- if not (eq $isValid true) }}
{{- fail "License must be accepted by setting license key to true" }}
{{- end }}

{{- $result := include "documentService.integerValidation" .Values.replicaCount -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for .Values.replicaCount" -}}
{{- end -}}

{{- $result := include "documentService.mandatoryArgumentsCheck" .Values.image.repository -}}
{{- if eq $result "false" -}}
{{- fail ".Values.global.image.repository cannot be empty." -}}
{{- end -}}

{{- $result := include "documentService.mandatoryArgumentsCheck" .Values.image.tag -}}
{{- if eq $result "false" -}}
{{- fail ".Values.global.image.tag cannot be empty" -}}
{{- end -}}

{{- $result := include "documentService.mandatoryArgumentsCheck" .Values.image.pullPolicy -}}
{{- if eq $result "false" -}}
{{- fail ".Values.global.image.pullPolicy cannot be empty" -}}
{{- end -}}

{{- $isValid := .Values.persistence.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Provide a valid value for field Values.persistence.enabled. Value can be either true or false." -}}
{{- end -}}

{{- $dynamicProvisioning := .Values.persistence.useDynamicProvisioning | toString -}}
{{- if not ( or (eq $dynamicProvisioning "false") (eq $dynamicProvisioning "true")) -}}
{{- fail "Provide a valid value for field Values.persistence.useDynamicProvisioning. Value can be either true or false." -}}
{{- end -}}

{{- $logsPVCEnabled := .Values.appLogsPVC.enabled | toString -}}
{{- if eq $logsPVCEnabled "true" -}}

{{- $isValid := .Values.appLogsPVC.accessMode -}}
{{- if not ( or (eq $isValid "ReadWriteOnce") (eq $isValid "ReadOnlyMany") (eq $isValid "ReadWriteMany")) -}}
{{- fail "Provide a valid value for Values.appLogsPVC.accessMode as one of these supported databases - ReadWriteOnce | ReadOnlyMany | ReadWriteMany" -}}
{{- end -}}

{{- end -}}
		
{{- if .Values.security.supplementalGroups -}}
    {{- range .Values.security.supplementalGroups }}
    	{{- $isValid := include "documentService.userOrGroupNameIDValidator" . -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Values.security.supplementalGroups is invalid. Either provide a numeric value for group ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid group name in an array." -}}
		{{- end -}}
    {{- end }}
{{- end -}}

{{- if .Values.security.fsGroup -}}
{{- $isValid := include "documentService.userOrGroupNameIDValidator" .Values.security.fsGroup -}}
{{- if eq $isValid "false" -}}
{{- fail "Values.security.fsGroup is invalid. Either provide a numeric value for group ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid group name." -}}
{{- end -}}
{{- end -}}

{{- if .Values.security.runAsGroup -}}
{{- $isValid := include "documentService.userOrGroupNameIDValidator" .Values.security.runAsGroup -}}
{{- if eq $isValid "false" -}}
{{- fail "Values.security.runAsGroup is invalid. Either provide a numeric value for group ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid group name." -}}
{{- end -}}
{{- end -}}

{{- if .Values.security.runAsUser -}}
{{- $isValid := include "documentService.userOrGroupNameIDValidator" .Values.security.runAsUser -}}
{{- if eq $isValid "false" -}}
{{- fail "Values.security.runAsUser is invalid. Either provide a numeric value for user ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid user name." -}}
{{- end -}}
{{- end -}}

{{- $isIngressEnabled := .Values.ingress.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Provide a valid value for Values.ingress.enabled. Value can be either false or true." -}}
{{- end -}}

{{- if (.Values.ingress.enabled | default true) -}}
	{{- $result := include "documentService.mandatoryArgumentsCheck" .Values.ingress.host -}}
	{{- if eq $result "false" -}}
	{{- fail ".Values.ingress.host cannot be empty" -}}
	{{- end -}}
	
	{{- if (.Values.ingress.tls.enabled | default true) -}}
		{{- $termination := lower (.Values.ingress.tls.termination | default "passthrough") -}}
		{{- if $termination -}}
			{{- if not ( or (eq $termination "passthrough") (eq $isValid "reencrypt")) -}}
		    {{- fail "Provide a valid value for Values.ingress.tls.termination. Value can be either passthrough | reencrypt." -}}
		    {{- end -}}
		{{- end -}}
	{{- end -}}
{{- end -}}

{{- $isValid := .Values.autoscaling.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Provide a valid value for Values.autoscaling.enabled. Value can be either false or true." -}}
{{- end -}}

{{- if eq $isValid "true" -}}
	{{- $isValid := include "documentService.integerValidation" .Values.autoscaling.minReplicas -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.autoscaling.minReplicas is not valid." -}}
	{{- end -}}

	{{- $isValid := include "documentService.integerValidation" .Values.autoscaling.maxReplicas -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.autoscaling.maxReplicas is not valid." -}}
	{{- end -}}

	{{- $isValid := include "documentService.integerValidation" .Values.autoscaling.targetCPUUtilizationPercentage -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.autoscaling.targetCPUUtilizationPercentage is not valid." -}}
	{{- end -}}
{{- end -}}

{{- $enableAppLogOnConsole := .Values.logs.enableAppLogOnConsole | toString -}}
{{- if not ( or (eq $enableAppLogOnConsole "false") (eq $enableAppLogOnConsole "true")) -}}
{{- fail "Provide a valid value for Values.logs.enableAppLogOnConsole. Value can be either false or true." -}}
{{- end -}}	

{{/*
Starting Validation of application configuration properties.
*/}}

{{- $isValid := include "documentService.isPortValid" .Values.application.server.port -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a valid values for server port." -}}
{{- end -}}

{{- $appSslEnabled := .Values.application.server.ssl.enabled | toString -}}
{{- if not ( or (eq $appSslEnabled "false") (eq $appSslEnabled "true")) -}}
{{- fail "Provide a valid value for Values.application.server.ssl.enabled. Value can be either false or true." -}}
{{- end -}}

{{- if (.Values.application.server.ssl.enabled | default true) -}}

{{- if (.Values.application.server.ssl.trustStoreSecretName) -}}
{{- $trustStoreType := lower .Values.application.server.ssl.trustStoreType -}}
{{- if not ( or (eq $trustStoreType "pkcs12") (eq $trustStoreType "jks")) -}}
{{- fail "Please specify .Values.application.server.ssl.trustStoreType as one of the supported values - pkcs12|jks" -}}
{{- end -}}
{{- end -}}

{{- end -}}

{{- $loglevel := upper .Values.application.logging.level -}}
{{- if $loglevel -}}
{{- if not (or (eq $loglevel "DEBUG") (eq $loglevel "ERROR") (eq $loglevel "OFF") (eq $loglevel "TRACE") (eq $loglevel "WARN") (eq $loglevel "FATAL") (eq $loglevel "INFO")) -}}
{{- fail "Provide a valid value for logging level. Valid values are DEBUG, ERROR, INFO, FATAL, OFF, TRACE or WARN" -}}
{{- end -}}
{{- end -}}

{{/*
Starting Validation of object store configuration properties.
*/}}

{{- $isValid := include "documentService.isPortValid" .Values.objectstore.port -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a valid values for object store port." -}}
{{- end -}}

{{- if .Values.objectstore.filePartSize -}}
{{- $filePartSizeValid := include "documentService.integerValidation" .Values.objectstore.filePartSize -}}
{{- if eq $filePartSizeValid "false" -}}
{{- fail "Provide a valid integer value for objectstore filePartSize." -}}
{{- end -}}
{{- end -}}	

{{- if .Values.objectstore.partBufferSize -}}
{{- $partBufferSizeValid := include "documentService.integerValidation" .Values.objectstore.partBufferSize -}}
{{- if eq $partBufferSizeValid "false" -}}
{{- fail "Provide a valid integer value for objectstore partBufferSize." -}}
{{- end -}}
{{- end -}}

{{- if .Values.objectstore.poolSizeTransferMgr -}}
{{- $poolSizeValid := include "integerValidation" .Values.objectstore.poolSizeTransferMgr -}}
{{- if eq $poolSizeValid "false" -}}
{{- fail "Provide a valid integer value for objectstore poolSizeTransferMgr." -}}
{{- end -}}
{{- end -}}

{{- if .Values.objectstore.connectionTimeout -}}
{{- $connectionTimeoutValid := include "documentService.integerValidation" .Values.objectstore.connectionTimeout -}}
{{- if eq $connectionTimeoutValid "false" -}}
{{- fail "Provide a valid integer value for objectstore connectionTimeout." -}}
{{- end -}}
{{- end -}}

{{- if .Values.objectstore.readTimeout -}}
{{- $readTimeoutValid := include "documentService.integerValidation" .Values.objectstore.readTimeout -}}
{{- if eq $readTimeoutValid "false" -}}
{{- fail "Provide a valid integer value for objectstore readTimeout." -}}
{{- end -}}
{{- end -}}

{{- if .Values.objectstore.useKeysFromSecrets }}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.secretName -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore secret name." -}}
{{- end -}}
{{- end -}}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.namespace -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore namespace." -}}
{{- end -}}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.region -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore region." -}}
{{- end -}}
{{- if or (ne .Values.objectstore.name "AWS") (ne .Values.objectstore.name "aws") -}}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.endpoint -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore endpoint." -}}
{{- end -}}
{{- end -}}


{{- $isValid := .Values.objectstore.proxyRequired | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Provide a valid value for field Values.objectstore.proxyRequired. Value can be either true or false." -}}
{{- end -}}
{{- if .Values.objectstore.proxyRequired -}}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.proxyHost -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore proxyHost." -}}
{{- end -}}
{{- $isValid := include "documentService.isPortValid" .Values.objectstore.proxyPort -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a valid values for objectstore proxyPort." -}}
{{- end -}}
{{- if .Values.objectstore.proxyCredentialRequired -}}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.proxyUsername -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore proxyUsername." -}}
{{- end -}}
{{- $isValid := include "documentService.mandatoryArgumentsCheck" .Values.objectstore.proxyPasswordSecretName -}}
{{- if eq $isValid "false" -}}
{{- fail "Provide a value for objectstore proxyPassword SecretName." -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- end -}}
