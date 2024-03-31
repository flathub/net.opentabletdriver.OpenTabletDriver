using System.Collections.Generic;
using System.IO;
using OpenTabletDriver.Plugin;

namespace OpenTabletDriver.Desktop
{
    public class PresetManager
    {
        public PresetManager()
        {
            PresetDirectory = new DirectoryInfo(AppInfo.Current.PresetDirectory);

            if (!PresetDirectory.Exists)
            {
                PresetDirectory.Create();
                Log.Write("Settings", $"The preset directory '{PresetDirectory.FullName}' has been created");
            }
        }

        public DirectoryInfo PresetDirectory { get; }

        private List<Preset> Presets { get; } = new List<Preset>();

        public IReadOnlyCollection<Preset> GetPresets() => Presets;

        public Preset FindPreset(string presetName)
        {
            return Presets.Find(preset => preset.Name == presetName);
        }

        private void Load()
        {
            foreach (var preset in PresetDirectory.EnumerateFiles("*.json"))
            {
                if (Settings.TryDeserialize(preset, out var settings))
                {
                    Presets.Add(new Preset(preset.Name.Replace(preset.Extension, string.Empty), settings));
                    Log.Write("Settings", $"Loaded preset '{preset.Name}'", LogLevel.Info);
                }
                else
                {
                    Log.Write("Settings", $"Invalid settings file '{preset.Name}' attempted to load into presets", LogLevel.Warning);
                }
            }
        }

        public void Refresh()
        {
            Presets.Clear();
            Load();
            Log.Write("Settings", $"Presets have been refreshed. Loaded {Presets.Count} presets.", LogLevel.Info);
        }
    }
}
