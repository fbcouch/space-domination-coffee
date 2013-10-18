// Generated by CoffeeScript 1.6.3
(function() {
  var AIShip,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.SpaceDom || (window.SpaceDom = {});

  window.SpaceDom.AIShip = AIShip = (function(_super) {
    __extends(AIShip, _super);

    function AIShip(image, game, proto) {
      this.image = image;
      this.game = game;
      this.proto = proto;
      AIShip.__super__.constructor.call(this, this.image, this.game, this.proto);
      this.ai = {
        patrol: {
          x: 0,
          y: 0,
          w: 1000,
          h: 1000
        },
        attack_range_sq: 500 * 500
      };
    }

    AIShip.prototype.update = function(delta) {
      var angle, diff, local, obj, _i, _len, _ref, _ref1;
      AIShip.__super__.update.call(this, delta);
      if (this.isRemove) {
        return;
      }
      if ((_ref = this.target) != null ? _ref.isRemove : void 0) {
        this.target = null;
      }
      if (this.target == null) {
        _ref1 = this.game.gameObjects;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          obj = _ref1[_i];
          if (obj instanceof SpaceDom.Ship && obj !== this) {
            if (((this.target == null) && AIShip.get_dist_sq(this, obj) < this.ai.attack_range_sq) || (AIShip.get_dist_sq(this, obj) < this.ai.attack_range_sq && AIShip.get_dist_sq(this, this.target) > AIShip.get_dist_sq(this, obj))) {
              this.target = obj;
            }
          }
        }
      }
      if (this.target != null) {
        this.targetPos = {
          x: this.target.x,
          y: this.target.y
        };
        if (this.canFire() && Math.random() < 0.05) {
          this.fire();
        }
      }
      if (this.targetPos == null) {
        this.targetPos = {
          x: Math.floor(Math.random() * this.ai.patrol.w + this.ai.patrol.x),
          y: Math.floor(Math.random() * this.ai.patrol.h + this.ai.patrol.y)
        };
      }
      local = this.parent.localToLocal(this.targetPos.x, this.targetPos.y, this);
      if (this.hitTest(local.x, local.y)) {
        this.targetPos = null;
      }
      if (this.targetPos != null) {
        if (this.target_box == null) {
          this.target_box = new createjs.Shape();
          this.target_box.graphics.beginFill("#0000ff").drawRect(0, 0, 10, 10);
          this.addChild(this.target_box);
        }
        this.target_box.x = local.x, this.target_box.y = local.y;
        angle = Math.atan2(this.targetPos.y - this.y, this.targetPos.x - this.x);
        angle *= SpaceDom.RAD_TO_DEG;
        diff = AIShip.get_angle_diff(this.rotation, angle);
        if (Math.abs(diff) > this.specs.rotate * delta) {
          this.rotate(delta, diff < 0);
        }
        return this.thrust(delta);
      }
    };

    AIShip.get_angle_diff = function(angle1, angle2) {
      var diff1, diff2;
      if (angle1 >= 360) {
        angle1 -= 360;
      }
      if (angle1 < 0) {
        angle1 += 360;
      }
      if (angle2 >= 360) {
        angle2 -= 360;
      }
      if (angle2 < 0) {
        angle2 += 360;
      }
      diff1 = angle2 - angle1;
      if (angle1 > 180) {
        angle1 -= 360;
      }
      if (angle2 > 180) {
        angle2 -= 360;
      }
      diff2 = angle2 - angle1;
      if (Math.abs(diff1) < Math.abs(diff2)) {
        return diff1;
      } else {
        return diff2;
      }
    };

    AIShip.get_dist_sq = function(ship1, ship2) {
      return Math.pow(ship1.x - ship2.x, 2) + Math.pow(ship1.y - ship2.y, 2);
    };

    return AIShip;

  })(SpaceDom.Ship);

}).call(this);

/*
//@ sourceMappingURL=AIShip.map
*/
