# New RESTful


from plaft.interfaces import Handler


class RESTfulBase(Handler):

    _model = None

    def get(self, model_id=None):
        """READ or LIST."""
        if model_id:
            try:
                model = self._model.find(int(model_id))
            except ValueError:
                self.status.BAD_REQUEST('Bad id %s' % model_id)
            else:
                if model:
                    self.render_json(model)
                else:
                    self.status.NOT_FOUND('Not found by id %s' % model_id)
        else:
            self.render_json(list(self._model.all(**self.query)))

    def post(self):
        """CREATE."""
        query = self.query

        if query:
            model = self._model.new(query)
            try:
                model.store()
            except IOError:
                self.status.INTERNAL_ERROR('Internal store')
            else:
                self.write_json('{"id":%d}' % model.id)
        else:
            self.status.BAD_REQUEST('No query')

    def put(self, model_id):
        """EDIT."""
        try:
            model = self._model.find(int(model_id))
        except ValueError:
            self.status.BAD_REQUEST('Bad id %s' % model_id)
        else:
            if model:
                query = self.query
                if query:
                    model << query
                    try:
                        model.store()
                    except IOError:
                        self.status.INTERNAL_ERROR('Internal store')
                    else:
                        self.write_json('{}')
                else:
                    self.status.BAD_REQUEST('No query')
            else:
                self.status.NOT_FOUND('Not found by id %s' % model_id)

    def delete(self, model_id):
        """REMOVE."""
        try:
            model = self._model.find(int(model_id))
        except ValueError:
            self.status.BAD_REQUEST('Bad id %s' % model_id)
        else:
            if model:
                model.delete()
            else:
                self.status.NOT_FOUND('Not found by id %s' % model_id)


class RESTfulNested(Handler):

    _model = None
    _parent = None

    def get(self, parent_id, model_id=None):
        """READ or LIST."""
        if model_id:
            try:
                model = self._model.find(int(model_id))
                # TODO: check parent
                # if self._parent.find(parent_id).
            except ValueError:
                self.status.BAD_REQUEST('Bad id %s' % model_id)
            else:
                if model:
                    self.render_json(model)
                else:
                    self.status.NOT_FOUND('Not found by id %s' % model_id)
        else:
            self.render_json(list(self._model.all(**self.query)))

    def post(self, parent_id):
        """CREATE."""
        try:
            parent = self._parent._model.find(int(parent_id))
        except ValueError:
            self.status.BAD_REQUEST('Bad parent id: ' + parent_id)
        else:
            if parent:
                query = self.query
                if query:
                    model = self._model.new(query)
                    try:
                        model.store()
                    except IOError:
                        self.status.INTERNAL_ERROR('Internal store')
                    else:
                        self.write_json('{"id":%d}' % model.id)
                else:
                    self.status.BAD_REQUEST('No query')
            else:
                self.status.NOT_FOUND('Parent not found: ' + parent_id)

    def put(self, parent_id, model_id):
        """EDIT."""
        try:
            model = self._model.find(int(model_id))
        except ValueError:
            self.status.BAD_REQUEST('Bad id %s' % model_id)
        else:
            if model:
                query = self.query
                if query:
                    model << query
                    try:
                        model.store()
                    except IOError:
                        self.status.INTERNAL_ERROR('Internal store')
                    else:
                        self.write_json('{}')
                else:
                    self.status.BAD_REQUEST('No query')
            else:
                self.status.NOT_FOUND('Not found by id %s' % model_id)

    def delete(self, parent_id, model_id):
        """REMOVE."""
        try:
            model = self._model.find(int(model_id))
        except ValueError:
            self.status.BAD_REQUEST('Bad id %s' % model_id)
        else:
            if model:
                model.delete()
            else:
                self.status.NOT_FOUND('Not found by id %s' % model_id)


class MetaRESTful(type):

    def __init__(cls, name, bases, dct):
        if 'RESTful' != name:
            from plaft.config import urls
            from webapp2 import Route
            from webapp2_extras.routes import PathPrefixRoute
            classname = name.lower()
            prefix = '/' + classname
            if '_parent' in dct:
                prefix = ('/%s/<parent_id:\\d+>%s'
                          % (dct['_parent'].__name__.lower(), prefix))
            routes = [
                Route(prefix, cls),
                Route(prefix + '/<model_id:\\d+>', cls)
            ]
            for key, value in dct.items():
                if (isinstance(value, type)
                    and issubclass(value, RESTfulMethod)):
                    method = ((val for val in value.__dict__.itervalues()
                               if not (val is None or isinstance(val, str)))
                              .next())
                    if method.func_code.co_argcount > 1:
                        varname = method.func_code.co_varnames[1]
                        # must be classname no modelname (to remove)
                        # if varname.startswith(classname):
                        modelname = cls._model.__name__.lower()
                        if varname.startswith(modelname):
                            key = '<%s_id:\\d+>/' % modelname + key
                    routes.append(Route('%s/%s' % (prefix, key), value))
            urls.append(PathPrefixRoute('/api', routes))
        super(MetaRESTful, cls).__init__(name, bases, dct)

    def __new__(cls, name, bases, dct):
        if 'RESTful' != name:
            bases += ((RESTfulNested if '_parent' in dct else RESTfulBase),)
        return super(MetaRESTful, cls).__new__(cls, name, bases, dct)


class RESTfulMethod(Handler):
    pass


class RESTful(Handler):

    __metaclass__ = MetaRESTful

    @classmethod
    def method(cls, func):
        """RESTful handler class from static method."""
        if isinstance(func, str):
            method = func

            def wrapper(func):
                """Create class with RESTful specific method."""
                return type(func.func_name, (RESTfulMethod,), {method: func})
            return wrapper
        return type(func.func_name, (RESTfulMethod,), {'get': func})
