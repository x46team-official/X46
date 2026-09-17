package com.x46.backend.master.entity;

import com.x46.backend.common.AbstractTenantEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "test_master")
public class TestMaster extends AbstractTenantEntity {

    @Column(name = "department_id", nullable = false)
    private UUID departmentId;

    @Column(name = "test_code", nullable = false)
    private String testCode;

    @Column(name = "test_name", nullable = false)
    private String testName;

    @Column(name = "display_name")
    private String displayName;

    @Column(name = "print_name")
    private String printName;

    @Column(name = "short_code")
    private String shortCode;

    @Column(name = "selling_price", nullable = false)
    private BigDecimal sellingPrice;

    @Column(name = "cost_price", nullable = false)
    private BigDecimal costPrice;

    @Column(name = "cprr", nullable = false)
    private BigDecimal cprr;

    @Column(name = "test_category_id")
    private UUID testCategoryId;

    @Column(name = "billing_category_id")
    private UUID billingCategoryId;

    @Column(name = "sample_type_id")
    private UUID sampleTypeId;

    @Column(name = "performing_lab_id")
    private UUID performingLabId;

    @Column(name = "outsource_center_id")
    private UUID outsourceCenterId;

    @Column(name = "worksheet_id")
    private UUID worksheetId;

    @Column(name = "worklist_id")
    private UUID worklistId;

    @Column(name = "test_method")
    private String testMethod;

    @Column(name = "test_type")
    private String testType;

    @Column(name = "tat_minutes")
    private Integer tatMinutes;

    @Column(name = "machine_test_code")
    private String machineTestCode;

    @Column(name = "consumption_group")
    private String consumptionGroup;

    @Column(name = "auto_approval")
    private boolean autoApproval;

    @Column(name = "automatically_authorize")
    private boolean automaticallyAuthorize;

    @Column(name = "nabl_accredited")
    private boolean nablAccredited;

    @Column(name = "mark_as_profile")
    private boolean markAsProfile;

    @Column(name = "two_step_verification")
    private boolean twoStepVerification;

    @Column(name = "authorize_only_by_authorizer")
    private boolean authorizeOnlyByAuthorizer;

    @Column(name = "outsource_test")
    private boolean outsourceTest;

    @Column(name = "notify_accession")
    private boolean notifyAccession;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    @Column(name = "description")
    private String description;

    public UUID getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(UUID departmentId) {
        this.departmentId = departmentId;
    }

    public String getTestCode() {
        return testCode;
    }

    public void setTestCode(String testCode) {
        this.testCode = testCode;
    }

    public String getTestName() {
        return testName;
    }

    public void setTestName(String testName) {
        this.testName = testName;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getPrintName() {
        return printName;
    }

    public void setPrintName(String printName) {
        this.printName = printName;
    }

    public String getShortCode() {
        return shortCode;
    }

    public void setShortCode(String shortCode) {
        this.shortCode = shortCode;
    }

    public BigDecimal getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(BigDecimal sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public BigDecimal getCprr() {
        return cprr;
    }

    public void setCprr(BigDecimal cprr) {
        this.cprr = cprr;
    }

    public UUID getTestCategoryId() {
        return testCategoryId;
    }

    public void setTestCategoryId(UUID testCategoryId) {
        this.testCategoryId = testCategoryId;
    }

    public UUID getBillingCategoryId() {
        return billingCategoryId;
    }

    public void setBillingCategoryId(UUID billingCategoryId) {
        this.billingCategoryId = billingCategoryId;
    }

    public UUID getSampleTypeId() {
        return sampleTypeId;
    }

    public void setSampleTypeId(UUID sampleTypeId) {
        this.sampleTypeId = sampleTypeId;
    }

    public UUID getPerformingLabId() {
        return performingLabId;
    }

    public void setPerformingLabId(UUID performingLabId) {
        this.performingLabId = performingLabId;
    }

    public UUID getOutsourceCenterId() {
        return outsourceCenterId;
    }

    public void setOutsourceCenterId(UUID outsourceCenterId) {
        this.outsourceCenterId = outsourceCenterId;
    }

    public UUID getWorksheetId() {
        return worksheetId;
    }

    public void setWorksheetId(UUID worksheetId) {
        this.worksheetId = worksheetId;
    }

    public UUID getWorklistId() {
        return worklistId;
    }

    public void setWorklistId(UUID worklistId) {
        this.worklistId = worklistId;
    }

    public String getTestMethod() {
        return testMethod;
    }

    public void setTestMethod(String testMethod) {
        this.testMethod = testMethod;
    }

    public String getTestType() {
        return testType;
    }

    public void setTestType(String testType) {
        this.testType = testType;
    }

    public Integer getTatMinutes() {
        return tatMinutes;
    }

    public void setTatMinutes(Integer tatMinutes) {
        this.tatMinutes = tatMinutes;
    }

    public String getMachineTestCode() {
        return machineTestCode;
    }

    public void setMachineTestCode(String machineTestCode) {
        this.machineTestCode = machineTestCode;
    }

    public String getConsumptionGroup() {
        return consumptionGroup;
    }

    public void setConsumptionGroup(String consumptionGroup) {
        this.consumptionGroup = consumptionGroup;
    }

    public boolean isAutoApproval() {
        return autoApproval;
    }

    public void setAutoApproval(boolean autoApproval) {
        this.autoApproval = autoApproval;
    }

    public boolean isAutomaticallyAuthorize() {
        return automaticallyAuthorize;
    }

    public void setAutomaticallyAuthorize(boolean automaticallyAuthorize) {
        this.automaticallyAuthorize = automaticallyAuthorize;
    }

    public boolean isNablAccredited() {
        return nablAccredited;
    }

    public void setNablAccredited(boolean nablAccredited) {
        this.nablAccredited = nablAccredited;
    }

    public boolean isMarkAsProfile() {
        return markAsProfile;
    }

    public void setMarkAsProfile(boolean markAsProfile) {
        this.markAsProfile = markAsProfile;
    }

    public boolean isTwoStepVerification() {
        return twoStepVerification;
    }

    public void setTwoStepVerification(boolean twoStepVerification) {
        this.twoStepVerification = twoStepVerification;
    }

    public boolean isAuthorizeOnlyByAuthorizer() {
        return authorizeOnlyByAuthorizer;
    }

    public void setAuthorizeOnlyByAuthorizer(boolean authorizeOnlyByAuthorizer) {
        this.authorizeOnlyByAuthorizer = authorizeOnlyByAuthorizer;
    }

    public boolean isOutsourceTest() {
        return outsourceTest;
    }

    public void setOutsourceTest(boolean outsourceTest) {
        this.outsourceTest = outsourceTest;
    }

    public boolean isNotifyAccession() {
        return notifyAccession;
    }

    public void setNotifyAccession(boolean notifyAccession) {
        this.notifyAccession = notifyAccession;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
