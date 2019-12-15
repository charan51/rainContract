const CropDamage = artifacts.require("CropDamageNew");

contract('CropDamage', (accounts) => {
    let instance;
    beforeEach(async () => {
        instance = await CropDamage.deployed({from: accounts[0]});
    });
    it('contract should have balance', async() => {
        let balance = await web3.eth.getBalance(instance.address);
        console.log(balance);
        assert.equal(balance, 100000, "Contract balance should have been");
    })
    it('Should select the admin from first account', async () => {
        
        const admin = await instance.admin.call();
        assert.equal(admin, accounts[0], "Admin must be from account[0]");
    });
    it('should add the farmer to smartcontract', async () => {
        const farmerAdd = await instance.addFarmer(123, "charan", "bangalore", { from: accounts[1] });
        assert.ok(farmerAdd, true, "Farmer added sussfully");
    });
    it('should calculate the premium', async () => {
        const total = await instance.calculatePremium(12, 12);
        assert.equal(total[0].toString(), '58', "total premium cost price");
        assert.equal(total[1].toString(), '230', "total coverage cost price");
    });
    it('should test policy buy', async () => {
        const buyPolicy = await instance.buyPolicy(123,12,12,222,1222,"bangalore", {from: accounts[1]});
        assert.ok(buyPolicy, "farmer bought policy succfully")
    });
   it('should get the farmer status', async() => {
       const farmerStatus = await instance.getFarmerStatus(123);
       assert.equal(farmerStatus, 0, "Farmer status to active");
   });
   it('should get the farmer status should not be Inactive', async() => {
    const farmerStatus = await instance.getFarmerStatus(123);
    assert.notEqual(farmerStatus, 1, "Farmer status to active");
});
    it('Should claim for the damage', async() => {
        await instance.claim_for_damage(123,"rain",{from: accounts[1]});
        const farmerStatus = await instance.getFarmerStatus(123);
        assert.equal(farmerStatus, 1, "Farmer status to inactive");
    });
});
