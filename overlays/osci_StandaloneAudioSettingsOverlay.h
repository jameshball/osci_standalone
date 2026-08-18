/*
  ==============================================================================

   This file is part of the osci_standalone module
   Copyright (c) 2026 James H Ball

  ==============================================================================
*/

#pragma once

namespace osci {

class StandaloneAudioSettingsOverlay final : public ComponentOverlay {
public:
    StandaloneAudioSettingsOverlay (std::unique_ptr<juce::Component> content,
                                    juce::Point<int> preferredContentSize)
        : ComponentOverlay (std::move (content),
                            "Audio/MIDI Settings",
                            preferredContentSize,
                            true)
    {
        setComponentID ("standaloneAudioSettingsOverlay");
    }

private:
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (StandaloneAudioSettingsOverlay)
};

inline StandaloneAudioSettingsOverlay* findStandaloneAudioSettingsOverlay (juce::Component& root)
{
    for (int i = 0; i < root.getNumChildComponents(); ++i)
    {
        auto* child = root.getChildComponent (i);

        if (auto* overlay = dynamic_cast<StandaloneAudioSettingsOverlay*> (child))
            return overlay;

        if (child != nullptr)
            if (auto* overlay = findStandaloneAudioSettingsOverlay (*child))
                return overlay;
    }

    return nullptr;
}

inline bool showStandaloneAudioSettingsOverlay (juce::Component& parent)
{
    if (auto* existing = findStandaloneAudioSettingsOverlay (parent))
    {
        existing->toFront (true);
        if (existing->isShowing()) {
            existing->grabKeyboardFocus();
        }
        return true;
    }

    auto* standalone = juce::StandalonePluginHolder::getInstance();
    if (standalone == nullptr)
        return false;

    auto content = standalone->createAudioSettingsComponent();
    if (content == nullptr)
        return false;

    const juce::Point<int> preferredContentSize { content->getWidth(), content->getHeight() };
    content->setColour (juce::ResizableWindow::backgroundColourId, Colours::veryDark().brighter (0.015f));

    OverlayComponent::show (parent,
                            std::make_unique<StandaloneAudioSettingsOverlay> (std::move (content),
                                                                              preferredContentSize));
    return true;
}

} // namespace osci
