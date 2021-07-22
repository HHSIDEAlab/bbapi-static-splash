---
layout: developers
title:  "Blue Button 2.0 API Docs"
date:   2017-10-30 09:21:12 -0500
description: Instructions for understanding and using the CMS Blue Button 2.0 API to get you up and running quickly.
landing-page: live
gradient: "blueberry-lime-background"
subnav-link-gradient: "blueberry-lime-link"
badge: documentation
permalink: "/developers/"
sections:
  - Overview
  - Try the API
  - Authorization
  - Core Resources
  - FHIR Data Model
  - Sample Beneficiaries
  - Production API Access
  - Developer Guidelines
  - Blue Button 2.0 API Implementation Guide
ctas:
  -
    title: Developer Sandbox
    link: https://sandbox.bluebutton.cms.gov/v1/accounts/mfa/login
  -
    title: Blue Button 2.0 API Blog
    link: /blog
---

## Overview

The Centers for Medicare and Medicaid Services (CMS) Blue Button 2.0 API enables Medicare beneficiaries to connect their Medicare claims data to the applications, services, and research programs they trust.

The CMS Blue Button 2.0 API:

- Enables a developer to register a beneficiary-facing application
- Enables a beneficiary to grant an application access to four years of their Part A, B, and D claims data
- Uses the [HL7 FHIR](https://www.hl7.org/fhir/) standard for beneficiary data and the [OAuth 2.0](https://oauth.net/2/) standard for beneficiary authorization

---

## Try the API

To join the Developer Sandbox, register a sample application and retrieve synthetic data for a sample Patient ID by calling the API, follow these four steps:

**Step 1:** [Join the Developer Sandbox](https://sandbox.bluebutton.cms.gov/v1/accounts/create) and register a sample application

Click "Add an Application" to register a new sample application and get a Client ID and Secret

**Step 2:** Generate a sample token

To test out the Blue Button API, you must first generate a sample token that represents a beneficiary granting consent.

To see a sample of Blue Button data you can access the Test Client. 

1.  If you are already logged in to the Developer portal, log out
2.  In the navigation bar on [https://sandbox.bluebutton.cms.gov](https://sandbox.bluebutton.cms.gov) click on "Test Client"
3.  Click "sample Authorization flow"
4.	Click the Authorization Link to authorize
5.  You will be redirected to your Medicare account. Login with one of the synthetic beneficiary accounts

	<div class="ds-c-alert ds-c-alert--hide-icon ds-u-margin-bottom--2">
      <div class="ds-c-alert__body">
        <h3 class="ds-c-alert__heading">Synthetic Beneficiary Accounts</h3>
        <p class="ds-c-alert__text">
          The first user is <strong>BBUser00000</strong> with password <strong>PW00000!</strong> and these sample users continue all the way to <strong>BBUser29999</strong> with password <strong>PW29999!</strong>
          <i>Note: the ! at the end of the password is required</i>
        </p>
      </div>
	</div>

6.  Click "Allow" to Authorize sharing
7.  Review the details returned from the Authorization flow
8.  Make some API calls for the beneficiary account you used to authorize access


**Step 3:** Call the API

Try this out in Postman:

1. 	From the Postman app, open a new tab
2. 	Paste the Request URL: 
	```
	https://sandbox.bluebutton.cms.gov/v1/fhir/Patient/-20140000008325
	```
3. 	Click "Authorization" and select type "OAuth 2.0"
4.  Click on "Get New Access Token"
5.  Enter the following parameters:

	**Token Name:** {The name of your app}

	**Grant Type:** Authorization Code (With PKCE)

	**Callback URL:** One of the redirect uris you registered for your app, for example:

	```
	http://localhost:3000
	```

	**Auth URL:** 

	```
	https://sandbox.bluebutton.cms.gov/v1/o/authorize/
	```

	**Access Token URL:** 

	```
	https://sandbox.bluebutton.cms.gov/v1/o/token/
	```

	**Client ID:** {The Client ID assigned to your App in the sandbox}

	**Client Secret:** {The Client Secret assigned to your App in the sandbox}

    **Code Challenge Method:** SHA-256

    **Code Verifier:** Leave blank and it'll be automatically generated

	**Scope:** 
	```
	patient/Patient.read patient/Coverage.read patient/ExplanationOfBenefit.read profile
	```
	
	*NOTE:* When a beneficiary is authorizing your application, they will have the ability to omit the `patient/Patient.read` scope. **Be sure that you build your application accordingly to handle a 403 error if a beneficiary decides to filter their demographic information.**
  
	**State:** A recommended value that you should use in your app

	**Client Authentication:** Select "Send as Basic Auth header"

6.  Click Request Token. You should see a pop up for your Medicare account. Login using one of the synthetic beneficiary accounts

	<div class="ds-c-alert ds-c-alert--hide-icon ds-u-margin-bottom--2">
    <div class="ds-c-alert__body">
      <h3 class="ds-c-alert__heading">Synthetic Beneficiary Accounts</h3>
      <p class="ds-c-alert__text">
			The first user is <strong>BBUser00000</strong> with password <strong>PW00000!</strong> and these sample users continue all the way to <strong>BBUser29999</strong> with password <strong>PW29999!</strong>

				<i>Note: the ! at the end of the password is required</i>
      </p>
    </div>
	</div>

7.  Authorize sharing by clicking "Allow" on the authorization screen
8.  When you return to the Postman workspace you should now be able to make requests to the API using the Bearer Token that will have been placed in the Header
7. 	Click "Send" and see the synthetic beneficiary's personal health information as a Patient FHIR Resource display under "Body" in Postman

Once you have the Bearer Token you can also use Curl to make queries as follows:

<pre>
curl --header "Authorization: Bearer YOUR TOKEN HERE" https://sandbox.bluebutton.cms.gov/v1/fhir/Patient/-20140000008325
</pre>


**Step 4:** View the API Response

In the API response for Patient -20140000008325 you will find:
- 32 total claims (140 total claim lines)
- 25 carrier claims (110 carrier claim lines)
- 2 inpatient claims (25 inpatient claim lines)
- 5 Part D events


**Step 5:** Accessing Synthetic Data
In order to access the full synthetic dataset for an individual synthetic beneficiary, 
you can do the following:
1. Set up your sandbox application
2. Log out of [https://sandbox.bluebutton.cms.gov](https://sandbox.bluebutton.cms.gov).
3. Access the authorization url at [https://sandbox.bluebutton.cms.gov/v1/o/authorize/](https://sandbox.bluebutton.cms.gov/v1/o/authorize/)

    *Note: The last backslash is important*.
    *Also remember to append ?client_id={your client_id assigned to the application you registered}*

4. You will be redirected to the Medicare authentication screen on. DO NOT ACCESS THIS PAGE DIRECTLY.
5. Use one of thirty thousand provided usernames and passwords.

    <div class="ds-c-alert ds-c-alert--hide-icon ds-u-margin-bottom--2">
      <div class="ds-c-alert__body">
        <h3 class="ds-c-alert__heading">Synthetic Beneficiary Accounts</h3>
        <p class="ds-c-alert__text">
          The first user is <strong>BBUser00000</strong> with password <strong>PW00000!</strong> and these sample users continue all the way to <strong>BBUser29999</strong> with password <strong>PW29999!</strong>
          <i>Note: the ! at the end of the password is required</i>
        </p>
      </div>
	</div>

6. Approve access for your application, which will now receive an access token, which can be used in the requests described above.

7. The authorization completes when you are redirected back to the Redirect_URI you specified when you registered your application.

---

## Authorization

To use the Blue Button 2.0 OAuth 2 a developer must [register their application](https://sandbox.bluebutton.cms.gov/v1/o/applications/).

A registered application is given a client ID and a client secret. The secret should only be used if it can be kept confidential, such as communication between your server and the Blue Button 2.0 API.

### Scopes

Access tokens have a scope, which defines what the access token can do and what resources it can access. For our purposes, scopes are primarily utilized to give Medicare beneficiaries more granular choice over what data they would like to share with applications. The Blue Button 2.0 API has implemented [HL7 FHIR Scopes](http://www.hl7.org/fhir/smart-app-launch/scopes-and-launch-context/) to manage access to beneficiary data. They look like this:

```
patient/Patient.read
```

```
patient/Coverage.read
```

```
patient/ExplanationOfBenefit.read
```

From the OpenID Connect specification we support:

```
profile
```

This gives access to the `/v1/connect/UserInfo` Endpoint.

Our OAuth screen gives beneficiaries the ability to choose whether or not to share their demographic information. **Your application will need to handle the return of a 403 status code** from the `/v1/fhir/Patient` and `/v1/connect/userinfo` endpoints.

<img style="width: 100%;" src="{{ site.baseurl }}/assets/img/docs/bene_auth_screen.png" alt="The OAuth screen with a choice for benes to share or withhold certain demographic information" />

If the beneficiary declines to share information that your application needs to function, you may display a message explaining why that information is needed and request reauthorization, or handle the collection of that information elsewhere within your application.

The default selection when a beneficiary reaches the authorization screen will be to share all data, including demographic data, with your application. If a beneficiary makes a selection as to whether or not they want to share demographic data with your application and later decides they want to change that selection, they'll need to be taken through the authorization flow again to make a different choice from the OAuth screen.

#### Ensuring you still get the data you need

Take the time to ensure that you have fallbacks in place if you are unable to access the `patient` or `userinfo` endpoints.

For example, if you are getting the `patient_ID` from the `v1/fhir/Patient` endpoint, we recommend getting that identifier from the initial authorization response, or another resource like `ExplanationOfBenefit` or `Coverage`.

#### Explanation of needed data to Medicare Beneficiaries

If information limited by a scope is required for your application to properly function and it is not possible to get the information in another endpoint, we recommend providing an explanation about why certain data is needed in your user flow.

For example, if you use demographic information to help beneficiaries autofill tedious data-entry, you might want to explain that benefit before they reach the authorization screen. **It is essential, however, that you give beneficiaries the full picture.** If they do share that data with you for one-time data entry, they should know how long you keep it and if it is used for any other purposes.

#### What if my application doesn't need demographic information from beneficiaries?

As stewards of sensitive data, it is important to adopt the practice of only asking for the data that is needed to perform a service for a beneficiary. As you register or edit an application in our Sandbox, you will see an option to choose whether or not your application needs to collect demographic information from beneficiaries.

If you choose not to collect demographic information, Medicare beneficiaries will see a simplified version of the OAuth screen as they no longer need to choose whether or not they want to share that information.
### Registering Your App for Mobile App Support

When you register your application in the Blue Button 2.0 API Developer Sandbox, you will want to specify a unique custom URI scheme. This should be a unique value that will not conflict with other custom URI schemes implemented on a user’s mobile device.

We recommend that you define your custom URI scheme using a reverse domain name notation. As we developed our own testing application, we implemented a custom URI scheme of:
- `gov.cms.bluebutton.oauthtester`

This equated to an `oauthtester` subdomain for the [bluebutton.cms.gov](bluebutton.cms.gov) domain.

The reverse DNS style custom URI scheme should then be coupled with the re-direct path on the mobile device that will handle the call back from the Blue Button 2.0 API.

For example:
``` python
tld.app.subdomain[.subsubdomain]:/callback/path/endpoint
```


### Redirect_URI

When creating an Application in the sandbox a redirect URI is required. This is the API endpoint on *your* system that receives the callback from the Blue Button 2.0 API after a beneficiary is passed to the Blue Button 2.0 API to authorize your application. 

Multiple redirect URIs can be entered in the Redirect_URI field. Each entry should be separated by a space or newline.

A `Redirect_URI` follows this format:
``` 
URLprotocol://[sub-domain.]domain_name[:port]/path
```

#### URL Protocol

Three URL protocols are supported, depending on the purpose:
- `http:// protocol`
- `https:// protocol`
- `custom_url:// protocol`

***`http:// protocol`***

(Works in: Sandbox only)

The `http://` format is only accepted in the sandbox environment. It is typically used by developers for local testing by using `http://localhost/` however, any domain name can be used.  

***`https://protocol`***

(Works in: Sandbox | Production)

The `https://` format is used for secure communication and is required for all applications in the production environment unless the application is using the Mobile OAuth method for handling callbacks.

***`custom_url:// protocol`***

(Works in: Sandbox | Production)

The `custom_url` protocol is used by mobile applications to handle communications directly with your application on a mobile device.

If you are using Mobile OAuth support for communication directly with a mobile device the `custom_url` should follow this format:
``` 
Top-level.domain(TLD).domain-name[.sub-domain][.app_name]
```

For example, if the Blue Button 2.0 API team created an application we might create a custom_url of:
``` 
gov.cms.bluebutton.oauthtester
```
This would then be incorporated into a redirect URI entry. Here is an example:
``` 
gov.cms.bluebutton.oauthtester:8080//bluebutton_app/callback.html
```

### Web Application Flow

To use this flow your application should be registered with `Client Type` set to `confidential` and
`Grant Type` set to `authorization-code`.

#### Request authorization from user

To allow a user to authorize your application, direct them to the Blue Button 2.0 API `authorize` endpoint.

The request must include the `response_type` set to `code`, your application's client_id, and your application's redirect_uri.  It is recommended to use a `state` parameter to better secure your application by using it to identify the authorization response. It is now recommended to implement PKCE for ALL OAuth flows, see the [Adding PKCE](#adding-pkce) section on how to implement it.

```
https://sandbox.bluebutton.cms.gov/v1/o/authorize/?client_id=swBu7LWsCnIRfu530qnfPw1y5vMmER3lAM2L6rq2
    &redirect_uri=http://localhost:8080/testclient/callback
    &response_type=code
    &state=8e896a59f0744a8e93bf2f1f13230be5
```

#### Exchange `code` for `token`

After visiting the authorization page
a user will be redirected back to
the `redirect_uri`
registered with
your application.

For example if
the `redirect_uri`
is `http://localhost:8080/testclient/callback`
BlueButton will redirect with this request.

```
GET http://localhost:8080/testclient/callback?code=TSjqiZCdJwGyytGjz2GzziPfHTJ6z2
    &state=8e896a59f0744a8e93bf2f1f13230be5
```

Your application can now
exchange the code
provided in the redirected request
for a full `token`. Send a `POST`
request to the BlueButton `token`
endpoint providing the `code`,
the application's `client_id`,
`client_secret`,
and `redirect_uri`.
Your request
must also specify the `grant_type`
which should always be `authorization_code`
for this flow.

```
curl -X POST "https://sandbox.bluebutton.cms.gov/v1/o/token/" \
    -u "swBu7LWsCnIRfu530qnfPw1y5vMmER3lAM2L6rq2:<client_secret>" \
    -d "code=TSjqiZCdJwGyytGjz2GzziPfHTJ6z2
	&grant_type=authorization_code
	&redirect_uri=http://localhost/testclient/callback"
```

Response
```
{
    "access_token": "oQlduHNr09GKCU506GOgp8OarrAy2q",
    "expires_in": 16768.523842,
    "token_type": "Bearer",
    "scope": "profile patient/Patient.read patient/ExplanationOfBenefit.read patient/Coverage.read"
    "refresh_token": "wDimPGoA8vwXP51kie71vpsy9l17HN"
}
```
### Adding the STATE parameter

To better protect the security of your application's users, it is recommended to utilize the "state" parameter.  

The primary purpose is to mitigate CSRF (Cross-site request forgery) type attacks. 

The flow for your application would look like the following:

* Your client should generate and store a sufficiently large random string value. For example, this could be a universally unique identifier (UUID) and should have at least 122 bits of entropy.
* This value is included as a "state" parameter in the initial /v1/o/authorize request. For example, a parameter similar to  "state=8e896a59f0744a8e93bf2f1f13230be5" is added.
* When the user is redirected back to your application's redirect_uri, it includes the same “state” parameter that it was given.
* Your client must validate that the "state" parameter equals the one that was previously stored (from your initial authorize request). If you receive a response that does not match, your client should exit the flow (since there may be a compromise). 
* Your client has now successfully correlated the original request with the call-back response received from the authentication.

If implementing PKCE, clients may opt to not use state, since similar CSRF protection is provided by it. However, the state may be useful to your application for non-security type purposes, such as encoding other information in it for the authorization response.

The following article has additional information about usage and the type of attack it helps to mitigate: https://auth0.com/docs/protocols/state-parameters

### Adding PKCE

PKCE stands for Proof Key for Code Exchange. PKCE is an extension of the Authorization code flow that protects from authorization code injection attacks. Implementing PKCE involves creating a secret that is used when exchanging the authorization code to obtain an access token. You can read more about it from the [OAuth docs](https://oauth.net/2/pkce/).
#### Getting Started
To implement PKCE you'll need to create a code-verifier which is then used to create a code challenge. They should be created using the following formula:
```
codechallenge = BASE64URL-ENCODE(SHA256(ASCII(codeverifier)))
```

The codeverifier is a random string between 43 and 128 characters. The characters can only be a-z, A-Z, 0-9, and special characters: "-"  "."  "_"  "~"

#### Typescript Example
```
import crypto from "crypto";
export type CodeChallenge = {
    codeChallenge: string,
    verifier: string
}
function base64URLEncode(buffer: Buffer): string {
    return buffer.toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

function sha256(str: string): Buffer {
    return crypto.createHash('sha256').update(str).digest();
}
export function generateCodeChallenge(): CodeChallenge {
    var verifier = base64URLEncode(crypto.randomBytes(32));
    return {
        codeChallenge: base64URLEncode(sha256(verifier)),
        verifier: verifier
    };
}
```

#### Request Templates

**Authorize**
```
/v1/o/authorize/?client_id=<client_id>&redirect_uri=<redirect>&
grant_type=authorization_code&
code=<received code>&
code_challenge=<code_challenge>&
code_challenge_method=S256
```

**Token**
```
/v1/o/token/?client_id=<client_id>&
redirect_uri=<redirect>&
client_secret=<client_secret>&
code=<access code from above request>&
code_verifier=<code verifier used to generate code challenge>&
grant_type=authorization_code&code=<received code>&
code_challenge=<code_challenge>
```

A coding example of an OAuth 2.0 and PKCE flow is available here: [Authorization Code with PKCE Flow - OAuth 2.0 Playground](https://www.oauth.com/playground/authorization-code-with-pkce.html)

## Core Resources

Base Request URL:

<pre>https://sandbox.bluebutton.cms.gov</pre>

### FHIR Resources:

- Explanation of Benefit
- Patient
- Coverage

### UserInfo:
- Get User Profile from an Authorization Token

As a security measure the date of birth, SSN, and HICN will not be provided by the CMS Blue Button 2.0 API.

We use [FHIR Extensions](https://www.hl7.org/fhir/extensibility.html#Extension) in our API responses.

**Explanation of Benefit FHIR Resource**

<pre>/v1/fhir/ExplanationOfBenefit/?patient=[fhir_id]</pre>

The above URL returns all of the beneficiary's Explanation of Benefit (sometimes referred to as an episode of care)
records as an [ExplanationOfBenefit FHIR Resource](https://www.hl7.org/fhir/explanationofbenefit.html).
The bulk of a beneficiary's data is contained within these ExplanationOfBenefit FHIR resources.  
Each one can be thousands of lines long.

<pre>curl --header "Authorization: Bearer AUTHORIZATION TOKEN"  "https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?patient=-20140000008325"</pre>

That API call will return an Explanation of Benefit that contains many FHIR resources and is typically thousands of lines long.  

[Learn more about the Explanation of Benefits FHIR resource in the Blue Button 2.0 API](/eob/)

<pre>
{
    "fullUrl": "https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/carrier-22011027731",
    "resource": {
        "resourceType": "ExplanationOfBenefit",
        "id": "carrier-22011027731",
        "contained": [
            {
                "resourceType": "ReferralRequest",
                "id": "1",
                "status": "completed",
                "subject": {
                    "reference": "Patient/-20140000008325"
                },
                "requester": {
                    "agent": {
                        "identifier": {
                            "system": "http://hl7.org/fhir/sid/us-npi",
                            "value": "999999999999"
                        }
                    }
                },
                "recipient": [
                    {
                        "identifier": {
                            "system": "http://hl7.org/fhir/sid/us-npi",
                            "value": "999999999999"
                        }
                    }
                ]
            }
        ]

        ...this is only a subset of the entire output...
</pre>

**Patient FHIR Resource**

<pre><code>HTTP GET /v1/fhir/Patient/[fhir_id]</code></pre>

The above URL returns the beneficiary's demographics and other administrative information as a [Patient FHIR Resource](https://www.hl7.org/fhir/patient.html).  This information is mostly contact information, not medical data.

<pre><code>curl --header "Authorization: Bearer AUTHORIZATION TOKEN"  "https://sandbox.bluebutton.cms.gov/v1/fhir/Patient/-20140000008325"</code></pre>

<pre>
    {
        "resourceType": "Patient",
        "id": "-20140000008325",
        "extension": [
            {
                "url": "https://bluebutton.cms.gov/resources/variables/race",
                "valueCoding": {
                    "system": "https://bluebutton.cms.gov/resources/variables/race",
                    "code": "1",
                    "display": "White"
                }
            }
        ],
        "identifier": [
            {
                "system": "http://bluebutton.cms.hhs.gov/identifier#bene_id",
                "value": "-20140000008325"
            },
            {
                "system": "http://bluebutton.cms.hhs.gov/identifier#hicnHash",
                "value": "2025fbc612a884853f0c245e686780bf748e5652360ecd7430575491f4e018c5"
            }
        ],
        "name": [
            {
                "use": "usual",
                "family": "Doe",
                "given": [
                    "Jane",
                    "X"
                ]
            }
        ],
        "gender": "unknown",
        "birthDate": "2014-06-01",
        "address": [
            {
                "district": "999",
                "state": "15",
                "postalCode": "99999"
            }
        ]
    }
</pre>

[Download a sample Patient FHIR Resource](/sample-patient-entry.json)

**Coverage FHIR Resource**

<pre>HTTP GET /v1/fhir/Coverage/?beneficiary=[fhir_id]</pre>

The above URL returns the beneficiary's Coverage information as an [Coverage FHIR Resource.](http://hl7.org/fhir/coverage.html)

<pre>curl --header "Authorization: Bearer AUTHORIZATION TOKEN"  "https://sandbox.bluebutton.cms.gov/v1/fhir/Coverage/?beneficiary=-20140000008325"
</pre>

<pre>
<code>
{
  "fullUrl": "https://sandbox.bluebutton.cms.gov/v1/fhir/Coverage/part-a-20140000008325",
  "resource": {
      "resourceType": "Coverage",
      "id": "part-a-20140000008325",
      "extension": [
          {
              "url": "https://bluebutton.cms.gov/resources/variables/ms_cd",
              "valueCoding": {
                  "system": "https://bluebutton.cms.gov/resources/variables/ms_cd",
                  "code": "10",
                  "display": "Aged without end-stage renal disease (ESRD)"
              }
          },
          {
              "url": "https://bluebutton.cms.gov/resources/variables/orec",
              "valueCoding": {
                  "system": "https://bluebutton.cms.gov/resources/variables/orec",
                  "code": "0",
                  "display": "Old age and survivor’s insurance (OASI)"
              }
          },
          {
              "url": "https://bluebutton.cms.gov/resources/variables/esrd_ind",
              "valueCoding": {
                  "system": "https://bluebutton.cms.gov/resources/variables/esrd_ind",
                  "code": "0",
                  "display": "the beneficiary does not have ESRD"
              }
          },
          {
              "url": "https://bluebutton.cms.gov/resources/variables/a_trm_cd",
              "valueCoding": {
                  "system": "https://bluebutton.cms.gov/resources/variables/a_trm_cd",
                  "code": "0",
                  "display": "Not Terminated"
              }
          }
      ]

    ...this is only a subset of the entire output...
</code>
</pre>


**Compress Resources for more efficient data transfers**

To improve the performance when transferring large data resources it is possible to turn on compression. Gzip
compression is turned off by default. Compression can be activated for the following content types:

- text/html
- text/plain
- application/json
- application/fhir+json

To activate compression add the following to the header:

<pre>
Accept-Encoding: gzip
</pre>

The minimum payload size we will gzip is 1 kilobyte. If the original uncompressed size of the payload is less than 1 kb,
we will not apply gzip compression to our response. Therefore, developers should ensure their applications handle
this scenario gracefully by checking for the **Content-Encoding: gzip** response header before trying to
decompress.

[Download a sample Coverage FHIR Resource](/sample-coverage-entry.json)

**Get User Profile for an Authorization Token**

<pre>HTTP GET /connect/userinfo </pre>

The UserInfo Endpoint is an OAuth 2.0 Protected Resource.The above URL fetches the fictitious beneficiary’s basic account information given an Authorization Token. This is most often used when creating an account within your application. An HTTP GET is called and the response is returned as JSON.

<pre>curl --header "Authorization: Bearer AUTHORIZATION TOKEN" "https://sandbox.bluebutton.cms.gov/v1/connect/userinfo"</pre>

<pre>
{
  "sub": "fflinstone",
  "prefered_username": "fflinstone",
  "given_name": "Fred",
  "family_name:, "Flinstone,
  "name": "Fred Flinstone",
  "email": "pebbles-daddy@example.com",
  "created": "2017-11-28",
  "patient": "123456789",
}
</pre>

### More Efficient Data Queries

#### Query by Type

Many developers are interested in specific claim types, such as PDE. The query by type feature will allow applications to request just those claims. This will enable applications to process and download data more quickly and efficiently.

`ExplanationOfBenefit` resources fall into 8 types:

- `CARRIER`
- `DME`
- `HHA`
- `HOSPICE`
- `INPATIENT`
- `OUTPATIENT`
- `PDE`
- `SNF`

By default, the FHIR API returns all of these claim types when requesting the EOB for a beneficiary. You can use the Type query parameter to request specific claim types. 

For example, to request only Part D drug claims, add the query parameter:

```
?type=pde
```

**To request multiple claim types, a list of comma-separated values can be given for the TYPE parameter.**

If multiple codes are specified, EOBs matching all of those claim types will be returned:

```
/v1/fhir/ExplanationOfBenefit?patient=123&type=carrier,dme,hha,hospice,inpatient,outpatient,snf
```

The full list of claim types are:

`carrier`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|carrier
```

`pde`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|pde
```

`dme`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|dme
```

`hha`
```
https://bluebutton.cms.gov/resources/codesystem/eob-type|hha
```

`hospice`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|hospice'
```

`inpatient`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|inpatient’
```

`outpatient`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|outpatient’
```

`snf`

```
https://bluebutton.cms.gov/resources/codesystem/eob-type|snf
```

It is important to use lower case when requesting a claim type. If you submit an invalid combination of claim types or use the wrong case you’ll see a message like this:

```
{
	“detail”: “not a valid value”
}
```

The status code for this message is a `400 Bad Request`.

### Query by Type Examples:

In the sandbox there are synthetic beneficiaries with three of the eight claim types:
- `carrier`
- `inpatient`
- `pde`

Let us take a synthetic beneficiary record:

Username: **BBUser20023** and Password **PW20023!**

The FHIR ID for this beneficiary is **-20140000000024**

Let us do a regular `ExplanationOfBenefit` request:

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/
```

This bundle identifies 148 claims, returning the first 10. Here is how the start of the bundle will look:

```
{
  “resourceType”: “Bundle”,
  “id”: “9562c9b7-df79-419a-a94b-ef8cc9347e0e”,
  “meta”: {
    “lastUpdated”: “2019-11-05T22:05:48.257-05:00”
  },
“type”: “searchset”,
“total”: 148,
“link”: [
  {
    “relation”: “first”,
    “Url”:    “https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit?_count=10&startIndex=0&patient=-20140000000024”
  },
…
```

There are three claim types in this beneficiary’s record:
- Carrier (44)
- Inpatient (1)
- PDE (103)

The queries to request each claim type individually would be:

**Carrier Claims**

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?type=carrier
```

Or

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?type=https://bluebutton.cms.gov/resources/codesystem/eob-type|carrier
```

**Inpatient Claims**

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?type=inpatient
```

Or

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?type=https://bluebutton.cms.gov/resources/codesystem/eob-type|inpatient
```

**PDE Claims**
Since many of our developers are interested in the Part D drug claims it is now possible to query for only PDE-type claims.

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?type=pde 
```

Or

```
https://sandbox.bluebutton.cms.gov/v1/fhir/ExplanationOfBenefit/?type=https://bluebutton.cms.gov/resources/codesystem/eob-type|pde
```

#### Query by "lastUpdated" Field

The HL7 FHIR specification provides a [Meta](https://www.hl7.org/fhir/resource.html#Meta) section in each resource. The `lastUpdated` field represents the date and time of the last update. This takes the format of an “instant” type:

```
YYYY-MM-DDThh:mm:ss.sss+zz:zz.
```

The HL7 FHIR specification also provides a `_lastUpdated` query parameter for the search operations on the end-points. By using the `_lastUpdated` query parameter, **an application will be able to request only the records that have changed before or after a specific date**. If you keep track of the date of a previous request, you can request just the changes since your previous request. The format of this request would be:

```
https://sandbox.bluebutton.cms.gov/v1/fhir/Patient?_id=-19990000000001&_lastUpdated=gt2020-02-13T08:00:00-05:00&_format=application%2Fjson%2Bfhir’
```
<div class="ds-c-alert ds-c-alert--hide-icon ds-u-margin-bottom--2">
  <div class="ds-c-alert__body">
    <h3 class="ds-c-alert__heading">Note:</h3>
    <p class="ds-c-alert__text">
      Do not input dates before 2020-02-12 with <code>_lastUpdated</code>. Limitations of our backend service prevent data before 2020-02-12 from being tagged correctly.
    </p>
  </div>
</div>

The output from that request would look like this:

```
/v1/fhir/Patient?_id=-19990000000001&_lastUpdated=gt2020-02-13T08:00:00-05:00&_format=application%2Fjson%2Bfhir’
{
	“resourceType”: “Bundle”,
  “id”: “7d8ff6a1-95f9-4210-b08b-58a96ea74494”,
  “meta”: {
    “lastUpdated”: “2020-02-14T08:57:16.641-05:00”
	},
“type”: “searchset”,
“total”: 1,
“link”: [
  {
    “relation”: “self”,
  “url”: “https://prod-sbx.bfdcloud.net/v1/fhir/Patient?_format=application%2Fjson%2Bfhir&_id=-19990000000001&_lastUpdated=gt2020-02-13T08%3A00%3A00-05%3A00”
  }
],
“entry”: [
  {
    “resource”: {
      “resourceType”: “Patient”,
      “id”: “-19990000000001”,
      “meta”: {
        “lastUpdated”: “2020-02-13T21:53:06.017-05:00”
    },
“extension”: [
…
```

 The BB2.0 API supports operators for less than (`lt`), greater than (`gt`), less than or equal (`le`), and greater than or equal (`ge`) the specified instant. It is also possible to specify a time interval by using two `_lastUpdated` parameters like this:

 ```
 /v1/fhir/ExplanationOfBenefit?patient=Patient/-19990000000001&_lastUpdated=gt2020-02-13T08:00:00-05:00&_lastUpdated=lt2020-02-14T08:00:00-05:00&_format=application%2Fjson%2Bfhir
 ```


## FHIR Data Model

We have mapped over 1,300 fields from the CMS claims data warehouse into FHIR.  These fields are surfaced across the Patient, Coverage and Explanation of Benefits FHIR resources.

- Beneficiary Enrollment Record
- Carrier Claims
- Durable Medical Equipment
- Home Health Agency Claims
- Hospice Claims
- Inpatient Claims
- Outpatient Claims
- Part D Events
- Skilled Nursing Facility Claims

The Blue Button 2.0 API FHIR data model leverages coding systems specific to Medicare billing forms and/or the Chronic Conditions Warehouse, FHIR and Industry Coding Systems.

For Example:

- [National Drug Code Directory](https://www.accessdata.fda.gov/scripts/cder/ndc/)
- [HL7 v3 Code System ActCode](http://hl7.org/fhir/v3/ActCode/cs.html)
- [ICD-10](http://hl7.org/fhir/sid/icd-10)

[View the full list of Blue Button 2.0 API FHIR Data Model Coding Systems and Identifiers](https://github.com/CMSgov/bluebutton-data-server/blob/master/dev/data-model.md)

**How Often Will New/Updated Data Be Available?**

Medicare Part A, B, and D claims data will be refreshed weekly.

Our schedules may vary depending on many things like maintenance, delayed delivery of claims to the CCW data warehouse, or additional data quality processing that's needed.

We recommend you have a daily job to fetch new claims data for your users. Please be responsible with your API usage and comply with the Service Management Rights to Limit conditions in the Blue Button 2.0 API Terms of Service.

**Synthetic Data**

The CMS Blue Button 2.0 API offers a synthetic data set for developers to test against. This means that each request returns a realistic value. For example, if a patient is prescribed the diabetes medication Metformin, the associated cost and date of this prescription will be accurate.

Please note that this synthetic data set does not represent a longitudinal patient view. The claims—though representative independently—are shuffled and randomly assigned to patients. To build the synthetic data set, we selected a number of random claims, and shuffling them like a deck of cards among a group of fictitious Patient IDs. This will allow developers to test the Blue Button 2.0 API system, but could result in a patient with records for contradictory procedures.

**Production Data**

The CMS Blue Button 2.0 API has at least one claim for over 53M beneficiaries.

Today, there are approximately 38M beneficiaries in traditional or fee-for-service Medicare.  The Blue Button 2.0 API has Part A/B/D data for those beneficiaries plus Part D data for some beneficiaries on Medicare Advantage plans.  

Part D has always been a separate program, but certain plans include both the MA benefits (Part C) and Part D.  As a result, Part D drug event data is collected separately from MA encounter data.  Part D drug event data for all participants in Part D has been collected by the agency since the program began in the mid-2000s.  

The API also has historical claims data going back four years.  All of these factors contribute to the 53M number we use to describe the total number of beneficiaries available via the Blue Button 2.0 API.

---

## Sample Beneficiaries

[CSV of 100 sample beneficiaries with rich claims data](/synthetic_users_by_claim_count_full.csv)

When getting started with the Blue Button 2.0 API, it can be overwhelming to understand all of the coding systems and types of data that can be found in the Explanation of Benefit FHIR resource.

Below are some hypothetical Beneficiaries that gives you a sense of what is found in claims data.

**Meet Lucille**

Lucille is a 70-year old female. She has non-small cell lung cancer. Prior to her diagnosis, Lucille was active and had no significant health issues. She went on daily walks around her neighborhood, did yoga and made a concerted effort to eat healthy. Lucille smoked cigarettes for a few years when she was a teenager, but she quit after her father passed away from lung cancer. Her only other family history is mild hypertension on her mother’s side.

Below are some examples you may find in the Explanation of Benefit FHIR resource for Lucille.

Office Visit

<pre>
  <code>
    "service": {
      "coding": [{
        "system": "https://www.cms.gov/Medicare/Coding/MedHCPCSGenInfo/index.html",
        "version": "0",
        "code": "99215"
  </code>
</pre>

Lung Biopsy

<pre>
  <code>
    "procedureCodeableConcept": {
      "coding": [{
        "system": "http://hl7.org/fhir/sid/icd-9-cm",
        "code": "3328"
 </code>
</pre>

Diagnostic Radiology

<pre>
  <code>
    "service": {
      "coding": [{
        "system": "https://www.cms.gov/Medicare/Coding/MedHCPCSGenInfo/index.html",
        "version": "0",
        "code": "70553"
 </code>
</pre>

Radiation Therapy

<pre>
  <code>
    "service": {
      "coding": [{
        "system": "https://www.cms.gov/Medicare/Coding/MedHCPCSGenInfo/index.html",
        "version": "9",
        "code": "77263"
  </code>
</pre>

Chemo

<pre>
  <code>
    "service": {
      "coding": [{
        "system": "https://www.cms.gov/Medicare/Coding/MedHCPCSGenInfo/index.html",
        "version": "0",
        "code": "96400"
  </code>
</pre>

**Meet Jack**

"Jack" is a hypothetical 70 year-old male with Type 2 Diabetes and high blood pressure. Jack takes daily medication and his Doctor told him he needs to lose weight. He takes Glimepiride to help control his blood sugar and previously was on Metformin.

[Learn more about "Jack" (PDF)](https://cmsgov.github.io/bluebutton-developer-help/Jack-Persona.pdf)

---

## Production API Access

In order to gain production access, an organization should start by reviewing the [Terms of Service](/terms/), [production access user guide](/guide/), and [checklist](/checklist/). Once an organization believes it is fulfilling all the requirements detailed in the checklist and is adherent to the terms of service, they should email [bluebuttonapi@cms.hhs.gov](bluebuttonapi@cms.hhs.gov) to set up a production access demonstration meeting with the CMS team. 

---

## Developer Guidelines

Below are guidelines you should follow to be successful in your Blue Button 2.0 API integration.

**Your Privacy Policy**

You will be asked to provide a URL to your privacy policy and terms and conditions when registering your app in the Blue Button 2.0 API Developer Portal.  These links should be easy to access and understand by a beneficiary using your app.  Consider using the [Model Privacy Notice](https://www.healthit.gov/policy-researchers-implementers/model-privacy-notice-mpn).

**Rate Limiting and Data Refresh**

Medicare Part A, B, and D claims data will be refreshed weekly.

Our schedules may vary depending on many things like maintenance, delayed delivery of claims to the CCW data warehouse, or additional data quality processing that's needed.

We recommend you have a daily or weekly job to fetch new claims data for your users.  Please be responsible with your API usage and comply with the Service Management Rights to Limit conditions in the [Blue Button 2.0 API Terms of Service](/terms/).

**Use of the Blue Button 2.0 API Logo**

The Blue Button 2.0 API logo and usage guidelines is detailed [here](https://www.healthit.gov/patients-families/blue-button/blue-button-image).

**Beneficiary Revokes Access**

A beneficiary may revoke access to your application via the Medicare website.  When you encounter an invalid token indicating a beneficiary has revoked access, you should make a reasonable attempt to handle that case making it easy for the beneficiary to understand what is happening with their Medicare data.

**"Medicare is unable to retrieve your data at this time due to an internal issue. Our team is aware of the issue and is working to resolve it. Please try again at a later time. We apologize for any inconvenience."**

If you or your users encounters this error message, know that our team is aware of the issue and is working to resolve it as quickly as possible.

---

## Blue Button 2.0 Implementation Guide

The Blue Button 2.0 API team has created a Blue Button 2.0 API Implementation Guide (BB2IG).
You can access the guide here: [Blue Button 2.0 API Implementation Guide](/assets/ig/index.html).

The BB2IG features nine profiles in this version of the guide:

<li><a href="/assets/ig/StructureDefinition-bluebutton-patient-claim.html" target="_blank">Blue Button 2.0 API Patient Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-carrier-claim.html" target="_blank">Blue Button 2.0 API Carrier Claim Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-dme-claim.html" target="_blank">Blue Button 2.0 API DME Claim Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-hha-claim.html" target="_blank">Blue Button 2.0 API HHA Claim Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-hospice-claim.html" target="_blank">Blue Button 2.0 API Hospice Claim Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-inpatient-claim.html" target="_blank">Blue Button 2.0 API Inpatient Claim Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-outpatient-claim.html" target="_blank">Blue Button 2.0 API Outpatient Claim Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-pde-claim.html" target="_blank">Blue Button 2.0 API Part D Event Profile</a></li>
<li><a href="/assets/ig/StructureDefinition-bluebutton-snf-claim.html" target="_blank">Blue Button 2.0 API SNF Claim Profile</a></li>

---
