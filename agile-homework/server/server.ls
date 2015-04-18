require ['fake-data-loader', 'app-engine'], (fake-data-loader, app-engine)-> 
  fake-data-loader.load! 
  app-engine.start!
