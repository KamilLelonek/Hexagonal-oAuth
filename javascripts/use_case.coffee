class @UseCase
  #------------------------#
  #     INITIALIZATION     #
  #------------------------#
  @userUuid    = ''
  @authToken   = ''
  @currentUser = settings : {}

  constructor: ->
    UseCase.userUuid  = Persistency.get 'user_uuid'
    UseCase.authToken = Persistency.get 'auth_token'
    UseCase.currentUser.settings = @extractUserSettings Persistency.get 'user_settings'

  setDependency: (@guiAdapter, @serverSide) =>
    @serverSide.loadUserData(@userLoaded, @userNotLoaded) if @isUserLoggedIn()

  isUserLoggedIn: -> UseCase.userUuid and UseCase.authToken

  resetCredentials: =>
    UseCase.userUuid = UseCase.authToken = undefined
    Persistency.clearAll()

  #------------------------#
  #      LOADING USER      #
  #------------------------#
  authorizeUser: (provider) =>
    @serverSide.authorizeUser(provider, @userAuthorized, @userNotAuthorized)

  userAuthorized : (data) =>
    @setCredentials data
    @serverSide.loadUserData(@userLoaded, @userNotLoaded)

  userNotAuthorized : (error) =>
    console.log error

  userLoaded: (userJson) =>
    UseCase.currentUser.email = userJson.email
    UseCase.currentUser.image = userJson.avatar_url
    @guiAdapter.userLoaded UseCase.currentUser

  userNotLoaded: (error) =>
    @guiAdapter.userNotLoaded error

  #-------------------------#
  #      MANAGING USER      #
  #-------------------------#
  setCredentials : (data) =>
    console.log data
    UseCase.currentUser.settings = @userSettings data
    UseCase.userUuid  = data.uuid
    UseCase.authToken = data.token
    Persistency.set('user_uuid',  UseCase.userUuid)
    Persistency.set('auth_token', UseCase.authToken)
    Persistency.set('user_settings', @buildUserSettings data )

  setPassword : (password) =>
    @serverSide.setPassword(password, @setPasswordSuccess, @setPasswordFailure)

  setPasswordSuccess : =>
    UseCase.currentUser.settings.has_password = true
    Persistency.set('user_settings', @buildUserSettings UseCase.currentUser.settings )
    @guiAdapter.passwordSet()

  setPasswordFailure : =>
    @guiAdapter.passwordNotSet()

  userSettings : (data) =>
    has_password : data.has_password
    new_user     : data.new_user
    new_provider : data.new_provider

  buildUserSettings   : (userSettings) =>
    JSON.stringify @userSettings(userSettings)

  extractUserSettings : (userSettings) =>
    try JSON.parse userSettings

  logout : =>
    @serverSide.logout @logoutDone, @logoutDone

  logoutDone : =>
    @resetCredentials()
    @guiAdapter.userLoggedOut()
