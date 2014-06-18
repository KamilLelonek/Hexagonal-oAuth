class @GuiAdapter
  setDependency : (@useCase) ->

  loadPage : =>
    @pageContent = $('main')
    @loadOAuth()

  loadOAuth : =>
    element = @compileElement 'login'
    @initializeProviders element
    @pageContent.replaceContent element

  initializeProviders : (element) =>
    useCase = @useCase
    socialBtn = element.find '.social'
    socialBtn.on 'click', (e) ->
      e.preventDefault()
      provider = $(this).data 'provider'
      useCase.authorizeUser provider

  userLoaded: (user) =>
    element = @compileElement 'content', user: user
    @buildLogoutAction element
    @buildSetPasswordAction element
    @pageContent.replaceContent element

  buildLogoutAction : (element) =>
    element.find('#btn-logout').on 'click', =>
      @useCase.logout()

  buildSetPasswordAction : (element) =>
    element.find('#btn-set-password').on 'click', (e) =>
      e.preventDefault()
      password = $('#new-password').val()
      @useCase.setPassword password

  passwordSet : =>
    $('#set-password').fadeOut()

  passwordNotSet : =>
    $('#message-set-password').text 'Password not set. Propably too short (min 6 length).'

  userLoggedOut : =>
    window.location = ''

  userNotLoaded:(error) =>
    $('#message').val error

  compileElement : (templateName, data = {}) =>
    $ Handlebars.templates[templateName](data)