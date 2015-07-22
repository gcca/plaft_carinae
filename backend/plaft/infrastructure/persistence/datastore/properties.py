from google.appengine.ext.ndb import model as ndb


Boolean = ndb.BooleanProperty
Integer = ndb.IntegerProperty
Float = ndb.FloatProperty
Blob = ndb.BlobProperty
Text = ndb.TextProperty
String = ndb.StringProperty
GeoPt = ndb.GeoPtProperty
Pickle = ndb.PickleProperty
Json = ndb.JsonProperty
Key = ndb.KeyProperty
BlobKey = ndb.BlobKeyProperty
DateTime = ndb.DateTimeProperty
Date = ndb.DateProperty
Time = ndb.TimeProperty
LocalStructured = ndb.LocalStructuredProperty
Generic = ndb.GenericProperty
Computed = ndb.ComputedProperty
Structured = ndb.StructuredProperty

PolyModel = polymodel.PolyModel


# vim: et:ts=4:sw=4
