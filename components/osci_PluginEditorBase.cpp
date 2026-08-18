/*
  ==============================================================================

   This file is part of the osci_standalone module
   Copyright (c) 2026 James H Ball

  ==============================================================================
*/

#include "osci_PluginEditorBase.h"

namespace osci {

PluginEditorBase::PluginEditorBase(juce::AudioProcessor& processor, juce::Colour standaloneBackground,
                                   int tooltipDelayMilliseconds)
    : juce::AudioProcessorEditor(processor), standaloneBackground(standaloneBackground) {
    tooltipWindow->setMillisecondsBeforeTipAppears(tooltipDelayMilliseconds);
    attachToStandaloneHost();
}

PluginEditorBase::~PluginEditorBase() {
    if (!juce::JUCEApplicationBase::isStandaloneApp()) {
        return;
    }

    auto* standalone = juce::StandalonePluginHolder::getInstance();
    if (standalone != nullptr) {
        standalone->showAudioSettingsOverlay = nullptr;
    }
}

void PluginEditorBase::parentHierarchyChanged() {
    configureStandaloneWindow();
}

bool PluginEditorBase::openStandaloneAudioSettings() {
    return showStandaloneAudioSettingsOverlay(*this);
}

void PluginEditorBase::attachToStandaloneHost() {
    if (!juce::JUCEApplicationBase::isStandaloneApp()) {
        return;
    }

    configureStandaloneWindow();
    auto* standalone = juce::StandalonePluginHolder::getInstance();
    if (standalone == nullptr) {
        return;
    }

    const juce::Component::SafePointer<PluginEditorBase> safeThis(this);
    standalone->showAudioSettingsOverlay = [safeThis] {
        return safeThis != nullptr && safeThis->openStandaloneAudioSettings();
    };
}

void PluginEditorBase::configureStandaloneWindow() {
    if (!juce::JUCEApplicationBase::isStandaloneApp()) {
        return;
    }

    auto* window = dynamic_cast<juce::DocumentWindow*>(getTopLevelComponent());
    if (window == nullptr && juce::TopLevelWindow::getNumTopLevelWindows() > 0) {
        window = dynamic_cast<juce::DocumentWindow*>(juce::TopLevelWindow::getTopLevelWindow(0));
    }
    if (window == nullptr) {
        return;
    }

    window->setBackgroundColour(standaloneBackground);
    window->setColour(juce::ResizableWindow::backgroundColourId, standaloneBackground);
}

} // namespace osci
