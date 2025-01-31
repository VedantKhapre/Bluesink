# Bluesink

Bluesink is a Bash script that manages PulseAudio Bluetooth sinks, allowing multiple Bluetooth audio devices to play audio simultaneously by creating and managing a combined audio sink.

## Features

- Create a combined audio sink from multiple Bluetooth devices
- List available Bluetooth audio sinks
- Show current audio sink status
- Undo combined sink configuration
- Detailed logging of operations

## Prerequisites

- Linux system with PulseAudio installed
- PulseAudio command-line utility (`pactl`)
- Connected Bluetooth audio devices

## Installation

1. Clone this repository or download the script:
```bash
git clone [repository-url]
```

2. Make the script executable:
```bash
chmod +x bluesink.sh
```

## Usage

The script can be run with various options:

```bash
./bluesink.sh [OPTION]
```
or just make it binary

```bash
sudo mv bluesink.sh /usr/local/bin
```

### Available Options

- No option: Creates a combined Bluetooth audio sink (default behavior)
- `--help, -h`: Shows the help message
- `--create`: Creates a combined Bluetooth audio sink
- `--undo`: Removes the combined Bluetooth audio sink
- `--list`: Lists available Bluetooth sinks
- `--status`: Shows current audio sink status

### Examples

1. Create a combined sink (default):
```bash
bluesink
```

2. List available Bluetooth sinks:
```bash
bluesink.sh --list
```

3. Show current audio configuration:
```bash
bluesink.sh --status
```

4. Remove combined sink:
```bash
bluesink.sh --undo
```

## How It Works

1. The script identifies connected Bluetooth audio devices
2. Creates a combined sink named "multi_bluetooth"
3. Sets the combined sink as the default audio output
4. All audio will be played through all connected Bluetooth devices simultaneously

## Troubleshooting

If you encounter issues:

1. Ensure all Bluetooth devices are properly connected
2. Check if PulseAudio is running
3. Verify that devices appear in the output of `--list`
4. Check the script's output for error messages

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
