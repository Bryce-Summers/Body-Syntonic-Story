// Generated by CoffeeScript 1.11.1

/*
    Place Class.
    Defines a place model.
    Written by Bryce Summers on 10.23.2017
        
    The User is always viewing a visual representation of a place model.
    There are also a set of active places currently in the model hiearchy handled by the scene object.
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BSS.Place_Model = (function(superClass) {
    extend(Place_Model, superClass);

    function Place_Model() {
      this._object_spawners = null;
      this._camera_model = new BSS.Camera_Model();
    }

    Place_Model.prototype.getCamera = function() {
      return this._camera_model;
    };

    Place_Model.prototype.setCamera = function(model) {
      return this._camera_model = model;
    };

    return Place_Model;

  })(BSS.Model);

}).call(this);
