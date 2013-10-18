// Generated by CoffeeScript 1.6.3
(function() {
  var GameObject, Particle,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.SpaceDom || (window.SpaceDom = {});

  GameObject = window.SpaceDom.GameObject;

  window.SpaceDom.Particle = Particle = (function(_super) {
    __extends(Particle, _super);

    function Particle(id, game) {
      var data, image, proto, spriteSheet;
      this.game = game;
      proto = this.game.preload.getResult('particles')[id];
      this.initialize();
      data = {
        images: (function() {
          var _i, _len, _ref, _results;
          _ref = proto.images;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            image = _ref[_i];
            _results.push(this.game.preload.getResult(image));
          }
          return _results;
        }).call(this),
        frames: proto.frames,
        animations: proto.animations
      };
      spriteSheet = new createjs.SpriteSheet(data);
      this.animation = new createjs.Sprite(spriteSheet, "anim");
      this.addChild(this.animation);
    }

    Particle.prototype.isComplete = function() {
      return this.animation.paused;
    };

    return Particle;

  })(createjs.Container);

}).call(this);

/*
//@ sourceMappingURL=Particle.map
*/