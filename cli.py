""
Command-line interface for TaskGuard.
"""
import argparse

def main():
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(description='TaskGuard - Task Management System')
    parser.add_argument('--version', action='version', version='%(prog)s 0.1.0')
    
    # Add subcommands
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Start command
    start_parser = subparsers.add_parser('start', help='Start the TaskGuard service')
    
    # Add more commands as needed
    
    args = parser.parse_args()
    
    if args.command == 'start':
        print("Starting TaskGuard...")
        # Add startup logic here
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
