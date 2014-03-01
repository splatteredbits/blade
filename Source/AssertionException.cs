namespace Blade
{
    public sealed class AssertionException : System.Exception
    {
        private readonly string[] _psStackTrace;

        public AssertionException(string message, string[] psStackTrace)
            : base(message)
        {
            _psStackTrace = psStackTrace;
        }

        public string[] PSStackTrace
        {
            get { return _psStackTrace; }
        }
    }
}
