// *******************************************************************
// A set of functions that deal with manipulation of the 
// micro-instructions used in the micromachine and also in
// the control unit.
//
function setKnobsAndSwitches(microInst)
{
  top.datapath.setKnob("sreg", "AAddr",getNumber(document.microprog["AAddr" + microInst].value,2,10,2));
  top.datapath.setKnob("sreg", "BAddr",getNumber(document.microprog["BAddr" + microInst].value,2,10,2));
  top.datapath.setKnob("salu", "ALU",getNumber(document.microprog["ALU" + microInst].value,2,10,2));
  top.datapath.setKnob("sreg", "CAddr",getNumber(document.microprog["CAddr" + microInst].value,2,10,2));

  top.memory.setRWAddress("MM" + getNumber(document.microprog["MMAddr" + microInst].value,2,10,5));

  if (document.microprog["SW" + microInst].value.charAt(0) == '1')
    top.datapath.setSwitch("CArrow","Closed");
  else
    top.datapath.setSwitch("CArrow","Open");

  if (document.microprog["SW" + microInst].value.charAt(1) == '1')
    top.datapath.setSwitch("toMemory","Closed");
  else
    top.datapath.setSwitch("toMemory","Open");

  if (document.microprog["SW" + microInst].value.charAt(2) == '1')
    top.datapath.setSwitch("fromMemory","Closed");
  else
    top.datapath.setSwitch("fromMemory","Open");

  if (document.microprog["SW" + microInst].value.charAt(3) == '1')
    top.datapath.setSwitch("bend","Closed");
  else
    top.datapath.setSwitch("bend","Open");
}

function setMicroInst(microInst)
{
  document.microprog["AAddr" + microInst].value = AADDR_VALUE;
  document.microprog["BAddr" + microInst].value = BADDR_VALUE;
  document.microprog["CAddr" + microInst].value = CADDR_VALUE;
  document.microprog["ALU" + microInst].value = ALU_VALUE;
  document.microprog["MMAddr" + microInst].value = MMADDR_VALUE;
  document.microprog["SW" + microInst].value = SWITCH_VALUE;
}

function clearMicroInst(microInst)
{
  AADDR_VALUE = document.microprog["AAddr" + microInst].value;
  BADDR_VALUE = document.microprog["BAddr" + microInst].value;
  CADDR_VALUE = document.microprog["CAddr" + microInst].value;
  ALU_VALUE = document.microprog["ALU" + microInst].value;
  MMADDR_VALUE = document.microprog["MMAddr" + microInst].value;
  SWITCH_VALUE = document.microprog["SW" + microInst].value;

  document.microprog["AAddr" + microInst].value = "";
  document.microprog["BAddr" + microInst].value = "";
  document.microprog["CAddr" + microInst].value = "";
  document.microprog["ALU" + microInst].value = "";
  document.microprog["MMAddr" + microInst].value = "";
  document.microprog["SW" + microInst].value = "";
}

function loadKnobsAndSwitches(microInst)
{
  var MMAddress, switchSettings;

  switchSettings = "";

  document.microprog["AAddr" + microInst].value = getNumber(top.datapath.getKnobSetting("AAddr"),10,2,2);
  document.microprog["BAddr" + microInst].value = getNumber(top.datapath.getKnobSetting("BAddr"),10,2,2);
  document.microprog["CAddr" + microInst].value = getNumber(top.datapath.getKnobSetting("CAddr"),10,2,2);
  document.microprog["ALU" + microInst].value = getNumber(top.datapath.getKnobSetting("ALU"),10,2,2);

  MMAddress = top.memory.getRWAddress();
  MMAddress = MMAddress.substring(2,MMAddress.length);
  document.microprog["MMAddr" + microInst].value = getNumber(MMAddress,10,2,5);

  if (top.datapath.document.CArrow.src.indexOf("Closed") != -1)
    switchSettings = switchSettings + '1';
  else
    switchSettings = switchSettings + '0';

  if (top.datapath.document.toMemory.src.indexOf("Closed") != -1)
    switchSettings = switchSettings + '1';
  else
    switchSettings = switchSettings + '0';

  if (top.datapath.document.fromMemory.src.indexOf("Closed") != -1)
    switchSettings = switchSettings + '1';
  else
    switchSettings = switchSettings + '0';

  if (top.datapath.document.bend.src.indexOf("Closed") != -1)
    switchSettings = switchSettings + '1';
  else
    switchSettings = switchSettings + '0';

  document.microprog["SW" + microInst].value = switchSettings;
}