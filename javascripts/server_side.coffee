class Ajax
  constructor: ->
    @baseUrl = "http://localhost:3000"

  doGet    : (requestData, success, error) => doAjax "GET",    requestData, success, error
  doPost   : (requestData, success, error) => doAjax "POST",   requestData, success, error
  doCreate : (requestData, success, error) => doAjax "POST",   requestData, success, error
  doChange : (requestData, success, error) => doAjax "POST",   requestData, success, error
  doDelete : (requestData, success, error) => doAjax "DELETE", requestData, success, error

  doAjax = (method, requestData, success, error) =>
    requestMethod =
      type    : method
      headers :
        'X-Auth-Token' : UseCase.authToken
      xhrFields :
        withCredentials : true
      success :                         (data) -> success(data)                  || console.log "#{this.action} successful"
      error   : (jqXHR, textStatus, errorName) -> error(jqXHR.status, errorName) || console.log "#{this.action} failed"

    $.ajax $.extend({}, requestMethod, requestData)

class @ServerSide extends Ajax
  constructor : ->
    super
    # https://oauth.io/
    OAuth.initialize 'O_AUTH_IO_TOKEN'

  authorizeUser: (provider, @success, @error) =>
    OAuth.popup provider, authorize : { display:"touch" },  (err, result) =>
      return @error err if err
      @handleResult provider, result

  handleResult: (provider, result) =>
    console.log result
    switch provider
      when 'facebook'
        result.get('/me').done (data) =>
          email = data.email
          accessToken = result.access_token
          @getStarted provider, email, accessToken
      when 'google_plus'
        result.get('/plus/v1/people/me').done (data) =>
          email = data.emails[0].value
          accessToken = result.access_token
          @getStarted 'google', email, accessToken
      when 'linkedin'
        # https://developer.linkedin.com/documents/field-selectors
        # https://developer.linkedin.com/documents/profile-fields
        result.get("v1/people/~:(first-name,last-name,picture-url,email-address,public-profile-url)?format=json").done (data) =>
          email = data.emailAddress
          accessToken = result.oauth_token
          secretToken = result.oauth_token_secret
          @getStarted provider, email, accessToken, secretToken
      else throw 'Unknown provider'

  getStarted : (provider, email, accessToken, secretToken) =>
    @doPost(
             url    : "#{@baseUrl}/oauth/get_started"
             action : 'getStarted'
             data   :
               provider     : provider
               email        : email
               access_token : accessToken
               secret_token : secretToken
             success : @success
             error   : @error
           )

  loadUserData : (success, error) =>
    @doGet(
            url    : "#{@baseUrl}/users/#{UseCase.userUuid}"
            action : 'loadUserData'
            success
            error
          )

  logout : (success, error) =>
    @doDelete(
               url    : "#{@baseUrl}/logout/#{UseCase.userUuid}"
               action : 'logout'
               success
               error
             )

  setPassword : (password, success, error) =>
    @doPost(
             url    : "#{@baseUrl}/oauth/#{UseCase.userUuid}/set_password"
             action : 'setPassword'
             data   :
               password : password
             success : success
             error   : error
           )
