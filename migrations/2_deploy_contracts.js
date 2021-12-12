const whitelist = require("../whitelist");

const Qey = artifacts.require("Qey");

module.exports = function (deployer) {
  deployer.deploy(Qey, whitelist);
};
