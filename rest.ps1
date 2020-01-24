
# API dev guide:
# https://github.com/reportportal/documentation/blob/master/src/md/src/DevGuides/reporting.md

$uri       = 'https://reportportal.arcade.ch'
$username  = 'ops'
$password  = 'XZyHrbWDpEW7EX766P6uS49666DRT6'
$data      = "grant_type=password&username=$username&password=$password"
$authBasic = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(('ui:uiman')))

# Request a UI token
$uiTokenResult = Invoke-RestMethod -Method 'Post' -Uri "$uri/uat/sso/oauth/token" -Body $data -Headers @{ Authorization = "Basic $authBasic" } -ContentType 'application/x-www-form-urlencoded' -UseBasicParsing
$uiTokenResult

# Request a API token with the UI token
$apiTokenResult = Invoke-RestMethod -Method 'Get' -Uri "$uri/uat/sso/me/apitoken" -Headers @{ Authorization = "Bearer $($uiTokenResult.access_token)" }
$apiTokenResult





# [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String('dWk6dWltYW4='))



# Invoke-RestMethod -Method 'Get' -Uri $uri -Headers @{ Authorization = 'Bearer {0}' -f }


# curl -X GET "$uri/api/v1/ops_test/launch?" -H "Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1Nzk3OTE0MzIsInVzZXJfbmFtZSI6Im9wcyIsImF1dGhvcml0aWVzIjpbIlJPTEVfVVNFUiJdLCJqdGkiOiJkYWZiMzhlZS0wMzAyLTQxZTgtYWM5ZS1mNzlhNjg2MjVkMTEiLCJjbGllbnRfaWQiOiJ1aSIsInNjb3BlIjpbInVpIl19.z6CDtUCfDlSW72tFTdczVArxt97uXtFd31VZLnGWurU"


# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1Nzk3OTE0MzIsInVzZXJfbmFtZSI6Im9wcyIsImF1dGhvcml0aWVzIjpbIlJPTEVfVVNFUiJdLCJqdGkiOiJkYWZiMzhlZS0wMzAyLTQxZTgtYWM5ZS1mNzlhNjg2MjVkMTEiLCJjbGllbnRfaWQiOiJ1aSIsInNjb3BlIjpbInVpIl19.z6CDtUCfDlSW72tFTdczVArxt97uXtFd31VZLnGWurU



# 1
# $headers = @{Authorization = "Bearer $bearer_token"}
# $response = Invoke-RestMethod -ContentType "$contentType" -Uri $url -Method $method -Headers $headers -UseBasicParsin




# http://rp.com/uat/sso/oauth/token with user credentials.

# curl --header "Content-Type: application/x-www-form-urlencoded" \
#      --request POST \
#      --data "grant_type=password&username=default&password=1q2w3e" \
#      --user "ui:uiman" \
#      http://rp.com