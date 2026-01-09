---
name: prd-writer
description: Creates comprehensive Product Requirements Documents (PRDs) for new features and products. Use when the user asks to write a PRD, create product requirements, document a feature spec, or plan a new product/feature implementation.
allowed-tools: Read, Grep, Glob, Write, AskUserQuestion
---

# PRD Writer

This skill helps you create well-structured Product Requirements Documents following industry best practices.

## When to Use This Skill

- User asks to "write a PRD" or "create a product requirements document"
- Planning a new feature or product
- Documenting feature specifications
- Need to align stakeholders on product direction

## PRD Structure

A comprehensive PRD should include:

### 1. Header Section
- **Title**: Clear, descriptive name
- **Author**: Who wrote this PRD
- **Date**: Creation/last update date
- **Status**: Draft, In Review, Approved, In Development, Completed
- **Version**: Track iterations

### 2. Executive Summary
- **Purpose**: What problem are we solving?
- **Solution**: High-level approach in 2-3 sentences
- **Success Metrics**: How will we measure success?
- **Target Users**: Who is this for?

### 3. Problem Statement
- Current pain points
- User stories illustrating the problem
- Impact if not solved
- Market context or competitive landscape

### 4. Goals and Objectives
- **Primary Goals**: What must this achieve?
- **Secondary Goals**: Nice-to-haves
- **Non-Goals**: Explicitly state what's out of scope
- **Success Metrics**: Specific, measurable KPIs

### 5. User Stories and Use Cases
Format: "As a [user type], I want to [action] so that [benefit]"

Include:
- Primary user flows
- Edge cases
- Error scenarios

### 6. Requirements

**Functional Requirements:**
- User-facing features
- System behaviors
- Data requirements
- Integration points

**Non-Functional Requirements:**
- Performance (response time, throughput)
- Security and compliance
- Scalability
- Reliability/uptime
- Accessibility

**Technical Requirements:**
- Platform/browser support
- API specifications
- Database schemas
- External dependencies

### 7. User Experience

- Wireframes or mockups (reference or describe)
- User flows and navigation
- UI components needed
- Interaction patterns
- Error states and messaging

### 8. Design Decisions

- Architecture choices
- Technology stack decisions
- Trade-offs considered
- Alternatives evaluated
- Rationale for chosen approach

### 9. Dependencies and Assumptions

**Dependencies:**
- Other teams or products
- External services/APIs
- Infrastructure requirements

**Assumptions:**
- User behavior
- Technical constraints
- Business constraints

### 10. Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Technical complexity | High | Medium | Spike/POC first |
| Resource constraints | Medium | High | Phased rollout |

### 11. Milestones

- **Phase 1**: MVP features
- **Phase 2**: Additional features
- **Phase 3**: Polish and optimization

Include:
- Development estimates
- Testing and QA
- Launch criteria
- Post-launch support

### 12. Open Questions

Track unresolved items:
- [ ] Question to be answered
- [ ] Decision needed by [date]
- [ ] Waiting on feedback from [stakeholder]

### 13. Appendix

- Research findings
- Competitive analysis
- User research data
- Technical specifications
- API documentation
- Database schemas

## PRD Writing Best Practices

### Be Specific and Measurable
- "The system should be fast" → "API responses must complete within 200ms for 95% of requests"

### Use Clear Language
- Avoid jargon unless necessary
- Define acronyms on first use
- Write for your audience (technical vs. non-technical stakeholders)

### Prioritize Requirements
Use MoSCoW method:
- **Must have**: Critical for launch
- **Should have**: Important but not critical
- **Could have**: Desirable if time permits
- **Won't have**: Out of scope for this version

### Include Visual Aids
- User flow diagrams
- System architecture diagrams
- Wireframes or mockups
- Data models
- Sequence diagrams for complex interactions

### Version Control
- Track changes between versions
- Note who requested changes and why
- Keep a changelog at the bottom

### Review Checklist
Before finalizing, verify:
- [ ] Problem statement is clear and validated
- [ ] Success metrics are measurable
- [ ] All stakeholders identified
- [ ] Requirements are unambiguous
- [ ] Edge cases considered
- [ ] Security and privacy addressed
- [ ] Performance requirements specified
- [ ] Dependencies documented
- [ ] Risks identified with mitigations

## Output Format

When creating a PRD, save it as:
- **Location**: `docs/prd/` directory (or project-specific location)
- **Filename**: `PRD-[feature-name]-YYYY-MM-DD.md`
- **Format**: Markdown for easy version control and collaboration

## Example PRD Snippet

```markdown
# PRD: User Authentication System

**Author**: Product Team
**Date**: 2025-01-09
**Status**: Draft
**Version**: 1.0

## Executive Summary

**Purpose**: Enable secure user authentication to protect user data and personalize experience.

**Solution**: Implement OAuth 2.0 based authentication with support for email/password and social login providers.

**Success Metrics**:
- 95% of users complete sign-up within 2 minutes
- Login success rate > 99%
- Zero security incidents in first 90 days

**Target Users**: All application users requiring account access

## Problem Statement

Currently, users cannot:
1. Create personal accounts
2. Save preferences or history
3. Access features requiring identity verification

This limits engagement and prevents personalization.

**User Story**: "As a returning user, I want to log in quickly so that I can access my saved data without re-entering information."

## Goals and Objectives

**Primary Goals**:
- Secure authentication with industry-standard protocols
- Sub-3-second login flow
- Support for password recovery

**Non-Goals** (v1.0):
- Multi-factor authentication (future iteration)
- Enterprise SSO integration (separate feature)
- Biometric authentication (mobile-only consideration)

...
```

## Questions to Guide PRD Creation

Before starting, gather answers to:

1. **What problem are we solving?** (Can you describe it in one sentence?)
2. **Who is the primary user?** (Can you name a specific persona?)
3. **How will we know this is successful?** (What metrics matter?)
4. **What's the MVP?** (What's the smallest useful version?)
5. **What are we NOT building?** (What's explicitly out of scope?)
6. **What could go wrong?** (What keeps you up at night about this?)
7. **Who needs to approve this?** (What stakeholders must sign off?)

## Workflow

1. **Research Phase**: Understand the problem (user interviews, data analysis)
2. **Draft PRD**: Create initial version with all sections
3. **Internal Review**: Get feedback from engineering, design, stakeholders
4. **Iterate**: Refine based on feedback
5. **Approval**: Get sign-off from decision makers
6. **Maintain**: Update as requirements evolve during development

---

**Remember**: A great PRD is a communication tool. It should help everyone understand WHAT we're building, WHY we're building it, and HOW we'll know it's successful.
