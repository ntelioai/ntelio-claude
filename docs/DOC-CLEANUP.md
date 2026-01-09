# Documentation Cleanup Audit

## Summary

| Category | Action | Count |
|----------|--------|-------|
| **DELETE** (obsolete) | Remove outdated docs | 2 |
| **UPDATE** (wrong project name) | Fix references | 2 |
| **CONSOLIDATE** (duplicates) | Keep one, delete other | 1 set |
| **KEEP** (current) | No action | 8+ |
| **REVIEW** (uncertain) | Needs manual review | 5+ |

---

## DELETE - Obsolete Documentation

### 1. `commerceGenie/docs/guides/configuration-guide.md`
**Reason**: Uses old `CONFIG.MASTER` single-file approach
**Replacement**: `ntelioMiddleware/docs/configuration.md` (ENV + CONFIG.APP with `_extends`)
**Action**: Delete file, update any references

### 2. `commerceGenie/docs/ai/scriptr.io/docs/` (entire directory)
**Reason**: Duplicate of `docs/scriptr.io/docs/` (older copy from Aug 21)
**Replacement**: Keep `docs/scriptr.io/docs/` (Dec 8 copy)
**Action**: Delete entire `docs/ai/scriptr.io/` directory

---

## UPDATE - Wrong Project References

### 1. `commerceGenie/docs/guides/business-object-guide.md`
**Issue**: Title says "ExpenseGenie", content is generic
**Action**: Update title to be generic or CommerceGenie-specific
**Lines to fix**:
- Line 3: "ExpenseGenie application" → "ntelio applications"
- Line 1891: "Expense" FCBO example → keep as example, it's generic

### 2. `commerceGenie/docs/guides/user-management-implementation-guide.md`
**Issue**: References "ExpenseGenie"
**Action**: Update to generic or CommerceGenie-specific
**Lines to fix**:
- Line 5: "ExpenseGenie" → "ntelio applications"

---

## CONSOLIDATE - Duplicate Documentation

### Scriptr.io Platform Docs
**Keep**: `commerceGenie/docs/scriptr.io/docs/`
**Delete**: `commerceGenie/docs/ai/scriptr.io/docs/`

**Alternative**: Move canonical copy to `ntelioMiddleware/.claude/docs/scriptr.io/` for shared access

---

## KEEP - Current Documentation

| File | Status | Notes |
|------|--------|-------|
| `ntelioMiddleware/docs/configuration.md` | ✅ Current | Canonical config guide |
| `ntelioMiddleware/docs/setup.md` | ✅ Current | Canonical setup guide |
| `ntelioMiddleware/README.md` | ✅ Current | Architecture overview |
| `commerceGenie/docs/guides/api-gateway-guide.md` | ✅ Current | API patterns |
| `commerceGenie/docs/guides/data-stores-guide.md` | ✅ Current | Document operations |
| `commerceGenie/docs/guides/scriptr.io-guide.md` | ✅ Current | Platform constraints |
| `commerceGenie/docs/guides/configure-waba-guide.md` | ✅ Current | WABA setup |
| `commerceGenie/CLAUDE.md` | ✅ Current | Main project guide |

---

## REVIEW - Needs Manual Decision

### PRD Files
| File | Question |
|------|----------|
| `docs/prd/PRD-commercegenie.md` | Is this the active product spec? |
| `docs/prd/PRD-web-ux-manager.md` | Is this feature implemented or planned? |
| `docs/prd/PRD-WA-marketing-automation.md` | Is this feature implemented or planned? |
| `docs/prd/PRD-Ecommerce-Website-2025-12-27.md` | Recent - likely active |

### Drive System Docs
| File | Question |
|------|----------|
| `docs/ai/drive/drive-architecture.md` | Is Drive feature still planned? |
| `docs/ai/drive/bundle-drive-solution.md` | Active or shelved? |
| `docs/ai/drive/bundle-drive-implementation-checklist.md` | Complete or abandoned? |

### Task/Plan Files
| File | Question |
|------|----------|
| `docs/tasks/storefront-implementation-tasks.md` | Complete? |
| `docs/CommerceGenie MVP Implementation Plan.md` | Complete? |
| `docs/whatsapp-commerce-implementation-spec.md` | Current? |
| `docs/ai/sessions/session-notes.md` | Delete (transient)? |

---

## CLAUDE.md Updates Needed

After cleanup, update `commerceGenie/CLAUDE.md`:

1. **Remove reference to deleted config guide**:
   - Line referencing `docs/guides/configuration-guide.md`
   - Point to `ntelioMiddleware/docs/configuration.md` instead

2. **Fix Scriptr.io docs references**:
   - Keep only `docs/scriptr.io/docs/` references
   - Remove `docs/ai/scriptr.io/docs/` references

3. **Add plugin section** (as planned)

---

## Recommended Cleanup Order

1. **Delete obsolete** - Remove configuration-guide.md and duplicate scriptr.io docs
2. **Update references** - Fix CLAUDE.md and any other files
3. **Fix project names** - Update ExpenseGenie → generic/CommerceGenie
4. **Review PRDs** - Quick scan to mark active vs archived
5. **Review plans** - Archive completed implementation plans

---

## Commands for Cleanup

```bash
# Delete obsolete config guide
rm commerceGenie/docs/guides/configuration-guide.md

# Delete duplicate scriptr.io docs
rm -rf commerceGenie/docs/ai/scriptr.io/

# Move canonical scriptr.io docs to shared location (optional)
mv commerceGenie/docs/scriptr.io/docs ntelioMiddleware/.claude/docs/scriptr.io/
```
