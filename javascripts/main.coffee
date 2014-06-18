$.fn.replaceContent = (element) ->
  this.empty()
  this.append element

useCase    = new UseCase()
guiAdapter = new GuiAdapter()
serverSide = new ServerSide()

guiAdapter.setDependency useCase
useCase   .setDependency guiAdapter,
                         serverSide

guiAdapter.loadPage()