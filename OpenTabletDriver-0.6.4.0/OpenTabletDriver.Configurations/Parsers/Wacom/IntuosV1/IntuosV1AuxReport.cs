using OpenTabletDriver.Plugin.Tablet;

namespace OpenTabletDriver.Configurations.Parsers.Wacom.IntuosV1
{
    public struct IntuosV1AuxReport : IAuxReport
    {
        public IntuosV1AuxReport(byte[] report)
        {
            Raw = report;

            var auxByte = report[4];
            AuxButtons = new bool[]
            {
                auxByte.IsBitSet(0),
                auxByte.IsBitSet(1),
                auxByte.IsBitSet(2),
                auxByte.IsBitSet(3),
                auxByte.IsBitSet(4),
                auxByte.IsBitSet(5),
                auxByte.IsBitSet(6),
                auxByte.IsBitSet(7),
            };
        }

        public byte[] Raw { set; get; }
        public bool[] AuxButtons { set; get; }
    }
}
