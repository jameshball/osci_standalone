# osci_standalone

Shared JUCE standalone wrapper module for osci applications.

## Use

Add the module to a Projucer project and set `JUCE_USE_CUSTOM_PLUGIN_STANDALONE_APP=1`.

`OSCI_STANDALONE_AUDIO_SETTINGS_MIN_CHANNELS` can be set by consumers that want the standalone audio settings dialog to expose at least a fixed number of input and output channels.

