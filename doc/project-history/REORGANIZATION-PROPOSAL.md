# Maru Project Reorganization Proposal

## Executive Summary

The Maru project has grown organically from a simple metacircular compiler to a sophisticated system with multiple backends, experimental features, and extensive testing infrastructure. The current directory structure no longer reflects this complexity, making navigation difficult and hindering development. This proposal outlines a comprehensive reorganization to improve clarity, maintainability, and developer experience.

## Current Issues

### 1. Root Directory Clutter
- **50+ experimental files** mixed with core components
- **Generated binaries** without clear purpose
- **Temporary build artifacts** polluting the workspace
- **No clear distinction** between stable and experimental code

### 2. File Proliferation
- **33 emit-* variants** representing different experiments
- **Multiple eval implementations** with unclear relationships
- **Test files scattered** throughout the project
- **No version control** for experimental iterations

### 3. Lost Documentation Context
- **CLAUDE.md stripped** of valuable implementation details
- **Documentation scattered** across multiple directories
- **No central development status** tracking
- **Historical context buried** in archive directories

### 4. Unclear Organization Patterns
- **Mixed paradigms**: Some files organized by function, others by feature
- **No clear boundaries** between core compiler and extensions
- **Generated files mixed** with source files
- **Test organization inconsistent** with modern practices

## Proposed Directory Structure

```
maru/
├── core/                      # Stable, production-ready compiler core
│   ├── boot.l                 # Bootstrap definitions
│   ├── emit.l                 # Current stable emitter
│   ├── eval.l                 # Current stable evaluator
│   ├── eval.k                 # Compiled evaluator
│   └── README.md              # Core component documentation
│
├── src/                       # Active development
│   ├── features/              # Feature-based organization
│   │   ├── port-streams/      # Port/stream implementation
│   │   ├── peg-compiler/      # PEG enhancements
│   │   ├── dotted-access/     # Dotted syntax feature
│   │   └── multimethod/       # Multi-method dispatch
│   │
│   ├── backends/              # Organized backend implementations
│   │   ├── c-backend/         # Standard C backend
│   │   ├── ir-backend/        # IR-based compilation
│   │   └── threaded-backend/  # Threaded code generation
│   │
│   └── lib/                   # Library extensions
│       ├── parser/
│       ├── pretty-print/
│       └── stream/
│
├── experiments/               # Experimental code (dated subdirectories)
│   ├── 2024-01-emit-threading/
│   ├── 2024-02-eval-variants/
│   └── README.md              # Experiment guidelines
│
├── build/                     # All generated artifacts
│   ├── generated/             # Generated C files
│   ├── binaries/              # Compiled executables
│   ├── intermediates/         # .o files, etc.
│   └── .gitignore             # Ignore all generated files
│
├── tests/                     # Comprehensive test suite
│   ├── unit/                  # Unit tests by component
│   ├── integration/           # Integration tests
│   ├── regression/            # Regression test suite
│   ├── experiments/           # Experimental test code
│   └── fixtures/              # Test data and helpers
│
├── tools/                     # Development utilities
│   ├── bootstrap/             # Bootstrap scripts
│   ├── analysis/              # Code analysis tools
│   └── migration/             # Migration helpers
│
├── examples/                  # Usage examples
│   ├── basic/                 # Basic usage patterns
│   ├── advanced/              # Advanced features
│   └── tutorials/             # Step-by-step guides
│
├── doc/                       # All documentation
│   ├── architecture/          # System architecture docs
│   ├── development/           # Development guides
│   ├── api/                   # API documentation
│   └── historical/            # Historical documentation
│
├── grammars/                  # Grammar definitions
├── arch/                      # Architecture-specific code
│
├── CLAUDE.md                  # Restored with current state
├── DEVELOPMENT.md             # Day-to-day development notes
├── MIGRATION-GUIDE.md         # File movement mapping
├── README.md                  # Project overview
└── Makefile                   # Updated build system
```

## Migration Plan

### Phase 1: Foundation (Immediate)
1. **Create new directory structure**
   ```bash
   mkdir -p src/{features,backends,lib}
   mkdir -p build/{generated,binaries,intermediates}
   mkdir -p tests/{unit,integration,regression,experiments,fixtures}
   mkdir -p experiments tools examples
   ```

2. **Move obvious files**
   - Core files → `core/`
   - Recent features → `src/features/`
   - Tests → `tests/`
   - Documentation → `doc/`

3. **Clean root directory**
   - Remove generated binaries
   - Archive temporary files
   - Update .gitignore

### Phase 2: Consolidation (1-2 days)
1. **Organize emit variants**
   - Identify current production version → `core/emit.l`
   - Group related experiments → `src/backends/`
   - Archive obsolete versions → `experiments/`

2. **Consolidate eval implementations**
   - Similar approach to emit files
   - Maintain clear lineage documentation

3. **Update import paths**
   - Search and replace relative imports
   - Test bootstrap process

### Phase 3: Build System (2-3 days)
1. **Restructure Makefile**
   - Use path variables
   - Separate concerns (bootstrap, test, clean)
   - Support new directory structure

2. **Update test runner**
   - Discover tests in new locations
   - Maintain backward compatibility

3. **Create build documentation**
   - Clear build instructions
   - Troubleshooting guide

### Phase 4: Documentation (1-2 days)
1. **Restore CLAUDE.md**
   - Current development status
   - Build instructions
   - Architecture overview
   - Development workflow

2. **Create DEVELOPMENT.md**
   - Active feature tracking
   - Known issues
   - Daily development notes

3. **Update README.md**
   - Reflect new structure
   - Quick start guide
   - Contribution guidelines

### Phase 5: Validation (1 day)
1. **Test complete system**
   - Bootstrap process
   - All test suites
   - Example programs

2. **Create migration report**
   - Document all changes
   - Note any issues
   - Provide rollback plan

## Benefits

### For Developers
- **Clear navigation**: Instantly find relevant files
- **Obvious boundaries**: Know what's stable vs experimental
- **Better organization**: Feature-based development
- **Clean workspace**: No clutter in root directory

### For the Project
- **Scalability**: Structure supports growth
- **Maintainability**: Clear organization principles
- **Professional appearance**: Modern project structure
- **Historical preservation**: Experiments archived properly

### For Contributors
- **Easy onboarding**: Clear where to add new features
- **Defined workflows**: Obvious development patterns
- **Test organization**: Know where to add tests
- **Documentation**: Centralized and comprehensive

## Implementation Guidelines

### File Movement Rules
1. **Preserve git history**: Use `git mv` for all moves
2. **Update imports atomically**: Change all references in one commit
3. **Test after each phase**: Ensure system still builds
4. **Document everything**: Track all movements in MIGRATION-GUIDE.md

### Naming Conventions
- **Features**: Use descriptive names (port-streams, not ps)
- **Experiments**: Date-prefixed directories (2024-01-description)
- **Tests**: Mirror source structure in tests/
- **Documentation**: Clear, hierarchical organization

### Quality Checks
- [ ] Bootstrap process works
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No broken imports
- [ ] Build system functional
- [ ] Examples run correctly

## Risk Mitigation

### Potential Issues
1. **Broken imports**: Mitigated by atomic updates and testing
2. **Lost files**: Create complete backup before starting
3. **Build failures**: Test each phase independently
4. **Team confusion**: Comprehensive migration guide

### Rollback Plan
1. Git history preserves all changes
2. Tag current state before migration
3. Document allows reconstruction
4. Phased approach enables partial rollback

## Timeline

- **Day 1**: Phase 1 (Foundation) + Phase 2 start
- **Day 2**: Complete Phase 2 + Phase 3 start  
- **Day 3**: Complete Phase 3 + Phase 4
- **Day 4**: Complete Phase 4 + Phase 5
- **Day 5**: Buffer for issues + final validation

## Conclusion

This reorganization will transform Maru from a project that has "grown organically" into a well-structured, professional compiler project. The investment in reorganization will pay dividends in improved developer productivity, easier onboarding, and better long-term maintainability.

The key is to preserve the project's history and experimental nature while providing clear structure for future development. By separating stable core from active development and experiments, we create a sustainable foundation for Maru's continued evolution.