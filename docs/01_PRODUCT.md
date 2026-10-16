# Package Overview

## Purpose
DesignUIKit is a modular Apple-platform toolkit for composing UIKit interfaces,
sharing foundational utilities, and binding components to Combine or RxSwift.

## Consumers
- UIKit applications that need reusable components and fluent composition.
- Feature modules that inject domain use cases into reactive ViewModels.

## Supported Scope
- Swift package products: DesignCore, DesignExts, DesignExternal, DesignUIKit,
  DesignCombineUIKit, and DesignRxUIKit.
- Supported deployment target: iOS 13+. tvOS support is discontinued.
- Swift tools version: 5.9; see [Package.swift](../Package.swift).
- Swift Package Manager is the supported distribution method.
- Mac Catalyst feasibility and validation: [platform support](15_PLATFORMS.md).

## Fast View Direction
- Compose concrete UIKit view instances through builders and fluent APIs.
- Prefer updating affected properties or children while preserving other views.
- The refactor branch adds opt-in keyed updates for stacks and their bindings.

## Exclusions
- Feature business logic, concrete domain use cases, and app navigation policy.
- Native AppKit support or replacing UIKit with SwiftUI.
- Archived source APIs excluded from Swift package targets.
