/*
  ==============================================================================

   This file is part of the osci_standalone module
   Copyright (c) 2026 James H Ball

  ==============================================================================
*/

#pragma once

namespace osci {

class PluginEditorBase : public juce::AudioProcessorEditor {
public:
    explicit PluginEditorBase(juce::AudioProcessor& processor,
                              juce::Colour standaloneBackground = Colours::veryDark(),
                              int tooltipDelayMilliseconds = 500);
    ~PluginEditorBase() override;

    void parentHierarchyChanged() override;
    bool openStandaloneAudioSettings();

private:
    void attachToStandaloneHost();
    void configureStandaloneWindow();

    const juce::Colour standaloneBackground;
    juce::SharedResourcePointer<CustomTooltipWindow> tooltipWindow;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PluginEditorBase)
};

} // namespace osci
