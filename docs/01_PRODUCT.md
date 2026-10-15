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
- Package deployment targets: iOS 13 and tvOS 15.
- Swift tools version: 5.9; see [Package.swift](../Package.swift).
- The CocoaPods specification is a separate distribution configuration.

## Fast View Direction
- Compose concrete UIKit view instances through builders and fluent APIs.
- Prefer updating affected properties or children while preserving other views.
- The refactor branch adds opt-in keyed updates for stacks and their bindings.

## Exclusions
- Feature business logic, concrete domain use cases, and app navigation policy.
- A requirement to support macOS or replace UIKit with SwiftUI.
- Archived source APIs excluded from Swift package targets.
