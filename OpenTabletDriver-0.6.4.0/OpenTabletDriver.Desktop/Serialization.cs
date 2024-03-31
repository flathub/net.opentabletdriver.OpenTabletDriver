using System.IO;
using Newtonsoft.Json;
using OpenTabletDriver.Desktop.Converters;
using OpenTabletDriver.Plugin;

namespace OpenTabletDriver.Desktop
{
    public static class Serialization
    {
        static Serialization()
        {
            serializer.Error += SerializationErrorHandler;
            serializer.Converters.Add(new VersionConverter());
        }

        private static readonly JsonSerializer serializer = new JsonSerializer
        {
            Formatting = Formatting.Indented
        };

        private static void SerializationErrorHandler(object sender, Newtonsoft.Json.Serialization.ErrorEventArgs args)
        {
            Log.Exception(args.ErrorContext.Error);
        }

        public static bool TryDeserialize<T>(FileInfo file, out T value)
        {
            try
            {
                value = Deserialize<T>(file);
                return true;
            }
            catch (JsonException)
            {
                value = default;
                return false;
            }
        }

        public static T Deserialize<T>(FileInfo file)
        {
            using (var fs = file.OpenRead())
                return Deserialize<T>(fs);
        }

        public static void Serialize(FileInfo file, object value)
        {
            if (file.Exists)
                file.Delete();

            using (var fs = file.Create())
                Serialize(fs, value);
        }

        public static T Deserialize<T>(Stream stream)
        {
            using (var sr = new StreamReader(stream))
            using (var jr = new JsonTextReader(sr))
                return Deserialize<T>(jr);
        }

        public static void Serialize(Stream stream, object value)
        {
            using (var sw = new StreamWriter(stream))
            using (var jw = new JsonTextWriter(sw))
                Serialize(jw, value);
        }

        public static T Deserialize<T>(JsonTextReader textReader)
        {
            return serializer.Deserialize<T>(textReader);
        }

        public static void Serialize(JsonTextWriter textWriter, object value)
        {
            serializer.Serialize(textWriter, value);
        }
    }
}
